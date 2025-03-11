import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notely/constants/text_font_style.dart';
import 'package:notely/features/lock_notes/presentation/widget/show_lock_dialog.dart';
import 'package:notely/helpers/navigation_service.dart';
import '../../../../constants/app_constants.dart';
import '../../../../helpers/di.dart';
import '../../../../helpers/helper_methods.dart';
import '../../../database/db_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  final VoidCallback onSave;
  int? noteId;

  NoteEditorScreen({this.note, required this.onSave, this.noteId});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final imagesData = ImagesData();
  final _titleController = TextEditingController();
  late QuillController _quillController;
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  bool _isStarred = false;
  bool _isLocked = false;
  bool _isNewNote = true;
  String content = '';
  String title = '';

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _loadNote();
    _loadPhotos(); // Ensure photos are loaded when the screen is initialized
  }

  Future<void> _loadPhotos() async {
    if (widget.noteId != null) {
      final photos = await DatabaseHelper().filterData(
        filed: 'note_id',
        value: widget.note!['id'],
        table: 'photos',
      );
      for (var photo in photos) {
        imagesData.addImage(
            ImageData(path: photo['path'], isNew: false, id: photo['id']));
      }
      setState(() {
        _photos = photos;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imagesData.addImage(ImageData(path: pickedFile.path, isNew: true));

      log(imagesData.images.length.toString());
      setState(() {});
    }
  }

  Future<void> _deletePhoto(int id) async {
    await DatabaseHelper().deletePhoto(id);
    _loadPhotos(); // Reload list after deleting
  }

  void _loadNote() {
    if (widget.note != null) {
      _isNewNote = false;
      widget.noteId = widget.note!['id'];
      _titleController.text = widget.note!['title'];
      _isStarred = widget.note!['starred'] == 1;
      _isLocked = widget.note!['locked'] == 1;
      title = widget.note!['title'];
      try {
        String noteContent = widget.note!['content'];
        dynamic decodedContent;
        try {
          decodedContent = jsonDecode(noteContent);
        } catch (e) {
          decodedContent = [
            {"insert": "$noteContent\n"}
          ];
        }

        _quillController = QuillController(
          document: Document.fromJson(decodedContent),
          selection: TextSelection.collapsed(offset: 0),
        );
        content = _quillController.document.toPlainText();
      } catch (e) {
        print("Error loading note: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveNote() async {
    String title = _titleController.text.trim();
    String contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    if (_isNewNote) {
      int noteId = await DatabaseHelper().addNote(
        title.isNotEmpty ? title : ' ',
        contentJson,
      );
      for (var image in imagesData.images) {
        if (image.isNew) {
          String? imagePath = await moveImageToPermanentPath(image.path);
          if (imagePath != null)
            await DatabaseHelper().insertPhoto(imagePath, noteId);
        }
        if (image.isDeleted) {
          // await DatabaseHelper().deletePhoto(image.id!);
        }
      }

      //  await DatabaseHelper().insertPhoto(file.path, widget.noteId!);
      setState(() {
        widget.noteId = noteId;
        _isNewNote = false;
      });
      // Reload photos after creating a new note
    } else {
      await DatabaseHelper()
          .updateNote(widget.noteId!, title, contentJson, starred: _isStarred);

      for (var image in imagesData.images) {
        if (image.isNew) {
          String? imagePath = await moveImageToPermanentPath(image.path);
          if (imagePath != null)
            await DatabaseHelper().insertPhoto(imagePath, widget.noteId!);
        }
        if (image.isDeleted) {
          await DatabaseHelper().deletePhoto(image.id!);
        }
      }
    }

    widget.onSave();
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  Future<bool> _onBackPressed() async {
    if (content != _quillController.document.toPlainText() ||
        title != _titleController.text) {
      appData.write(
          kEditCount, '${_titleController.text} ${getFormattedDate()}');
    }
    await _saveNote();
    return Future.value(true);
  }

  void _toggleStarred() {
    setState(() {
      _isStarred = !_isStarred;
    });
    _saveNote();
  }

  void _lockNote() {
    if (widget.note != null) {
      showLockNotesDialog(
        context,
        widget.note!['id'],
        () => setState(() => _isLocked = true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            _isNewNote ? 'New Note' : 'Edit Note',
            style: TextFontStyle.textStylec17c000000Poppins400,
          ),
          actions: [
            IconButton(onPressed: _pickImage, icon: Icon(Icons.photo)),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              onSelected: (String value) {
                if (value == "starred") {
                  _toggleStarred();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "starred",
                  child: Row(
                    children: [
                      Icon(_isStarred ? Icons.star : Icons.star_border,
                          color: _isStarred ? Colors.amber : Colors.black),
                      SizedBox(width: 10),
                      Text("Starred"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "lock",
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.black),
                      SizedBox(width: 10.w),
                      Text("Lock"),
                    ],
                  ),
                  onTap: _lockNote,
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText:
                            'Title (optional)', // Indicate that title is optional
                        border: InputBorder.none,
                        hintStyle:
                            TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        QuillEditor.basic(
                          controller: _quillController,
                          configurations: QuillEditorConfigurations(
                            placeholder: 'Write your note.....',
                            customStyleBuilder: (attribute) =>
                                TextStyle(fontSize: 16.sp),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                        ),
                        imagesData.images
                                .where((element) => element.isDeleted == false)
                                .toList()
                                .isEmpty
                            ? Center(child: Text(''))
                            : SizedBox(
                                height: 100,
                                child: GridView.builder(
                                  padding: EdgeInsets.all(8),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: imagesData.images
                                      .where((element) =>
                                          element.isDeleted == false)
                                      .length,
                                  itemBuilder: (context, index) {
                                    final photo = imagesData.images[index];
                                    log(photo.path);
                                    return Stack(
                                      children: [
                                        Image.file(
                                          File(
                                            imagesData.images
                                                .where((element) =>
                                                    element.isDeleted == false)
                                                .toList()[index]
                                                .path,
                                          ),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                imagesData.images
                                                    .where((element) =>
                                                        element.isDeleted ==
                                                        false)
                                                    .toList()[index]
                                                    .isDeleted = true;
                                                setState(() {});
                                              }),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                  QuillToolbar.simple(
                    controller: _quillController,
                    configurations: QuillSimpleToolbarConfigurations(
                        multiRowsDisplay: false),
                  ),
                ],
              ),
      ),
    );
  }
}

class ImageData {
  final String path;
  bool isDeleted;
  bool isNew;
  int? id;
  ImageData(
      {required this.path,
      this.isDeleted = false,
      this.isNew = false,
      this.id});
}

class ImagesData {
  List<ImageData> images = [];
  addImage(ImageData image) {
    images.add(image);
  }
}
