import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notely/constants/text_font_style.dart';
import 'package:notely/features/lock_notes/presentation/widget/show_lock_dialog.dart';
import 'package:notely/helpers/navigation_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_constants.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/di.dart';
import '../../../../helpers/helper_methods.dart';
import '../../../database/db_helper.dart';
import '../../../lock_notes/presentation/widget/show_unlock_dialog.dart';
import '../../../theme_controller/theme_controller.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  final VoidCallback onSave;
  int? noteId;

  NoteEditorScreen({this.note, required this.onSave, this.noteId});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final ThemeController themeController = Get.find<ThemeController>();
  final imagesData = ImagesData();
  final _titleController = TextEditingController();
  late QuillController _quillController;
  List<Map<String, dynamic>> _photos = [];
  List<Map<String, dynamic>> _lockedNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = true;
  bool _isStarred = false;
  bool _isLocked = false;
  bool _isNewNote = true;
  String content = '';
  String title = '';
  String? password;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _loadNote();
    _loadPhotos();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
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
      if (!_quillController.document.isEmpty()) {
        int noteId = await DatabaseHelper().addNote(
          title.isNotEmpty ? title : '',
          contentJson,
        );
        if (_isLocked) {
          await DatabaseHelper().lockNote(noteId, password!);
        }

        for (var image in imagesData.images) {
          if (image.isNew) {
            String? imagePath = await moveImageToPermanentPath(image.path);
            if (imagePath != null)
              await DatabaseHelper().insertPhoto(imagePath, noteId);
          }
          if (image.isDeleted) {}
        }

        setState(() {
          widget.noteId = noteId;
          _isNewNote = false;
        });
      }
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

    try {
      await _saveNote();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e')),
      );
      return false;
    }
  }

  void _toggleStarred() {
    setState(() {
      _isStarred = !_isStarred;
    });
    _saveNote();
  }

  void _loadLockedNotes() async {
    List<Map<String, dynamic>> lockedNotes =
        await DatabaseHelper().getLockedNotes();
    setState(() {
      _lockedNotes = lockedNotes;
      _filteredNotes = lockedNotes;
    });
  }

  Future<void> _lockNote() async {
    if (widget.note != null) {
      final filterLockNote = await DatabaseHelper()
          .filterData(filed: 'id', table: 'notes', value: widget.noteId!);
      if (_isLocked) {
        showUnlockDialog(
            context, widget.noteId!, filterLockNote.first['password'], () {
          _loadLockedNotes();
        });
      } else {
        // Lock the note
        showLockNotesDialog(
          context,
          widget.note!['id'],
          () => setState(() {
            _isLocked = true;
            _saveNote(); // Save after locking
          }),
        );
      }
    } else {
      if (_isLocked) {
        showLocalUnlockDialog(context, password!, () {
          setState(() {
            _isLocked = false;
          });
        });
      } else {
        showLockLocal(context, (pass) {
          password = pass;
          _isLocked = true;
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: themeController.isDarkMode.value
            ? Color.fromARGB(255, 20, 20, 20)
            : AppColors.allPrimaryColor,
        appBar: AppBar(
          backgroundColor: themeController.isDarkMode.value
              ? Color.fromARGB(255, 20, 20, 20)
              : AppColors.allPrimaryColor,
          title: Text(
            _isNewNote ? 'New Note' : 'Edit Note',
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
                          color: _isStarred ? Colors.amber : Colors.white),
                      SizedBox(width: 10),
                      Text("Starred"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "lock",
                  child: Row(
                    children: [
                      Icon(_isLocked ? Icons.lock_open : Icons.lock),
                      SizedBox(width: 10.w),
                      Text(_isLocked ? "Unlock" : "Lock"),
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
                        hintText: 'Title (optional)',
                        border: InputBorder.none,
                        hintStyle:
                            TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          QuillEditor.basic(
                            controller: _quillController,
                            configurations: QuillEditorConfigurations(
                              placeholder: 'Write your note.....',
                              customStyleBuilder: (attribute) {
                                if (attribute.key == 'a') {
                                  return TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16.sp,
                                  );
                                }
                                return TextStyle(fontSize: 16.sp);
                              },
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              onLaunchUrl: (String url) async {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Link Options'),
                                    content: Text(url),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _launchUrl(url);
                                        },
                                        child: Text('Open'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Clipboard.setData(
                                              ClipboardData(text: url));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Link copied to clipboard')),
                                          );
                                        },
                                        child: Text('Copy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              },
                            ),
                          ),
                          imagesData.images
                                  .where(
                                      (element) => element.isDeleted == false)
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
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 400,
                                                    child: PhotoView(
                                                      imageProvider: FileImage(
                                                          File(photo.path)),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Image.file(
                                              File(
                                                imagesData.images
                                                    .where((element) =>
                                                        element.isDeleted ==
                                                        false)
                                                    .toList()[index]
                                                    .path,
                                              ),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
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
                  ),
                  QuillToolbar.simple(
                    controller: _quillController,
                    configurations: QuillSimpleToolbarConfigurations(
                      multiRowsDisplay: false,
                      showFontSize: false,
                      showFontFamily: false,
                    ),
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
