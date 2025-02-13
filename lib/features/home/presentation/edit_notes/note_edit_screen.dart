// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:notely/constants/text_font_style.dart';
// import 'package:notely/features/lock_notes/presentation/widget/show_lock_dialog.dart';
// import 'package:notely/helpers/navigation_service.dart';
// import '../../../database/db_helper.dart';

// // ignore: must_be_immutable
// class NoteEditorScreen extends StatefulWidget {
//   final Map<String, dynamic>? note;
//   final VoidCallback onSave;
//   int? noteId; // Must be mutable for dynamic updates

//   NoteEditorScreen({this.note, required this.onSave, this.noteId});

//   @override
//   _NoteEditorScreenState createState() => _NoteEditorScreenState();
// }

// class _NoteEditorScreenState extends State<NoteEditorScreen> {
//   final _titleController = TextEditingController();
//   late QuillController _quillController;
//   bool _isLoading = true;
//   bool _isStarred = false;
//   bool _isLocked = false;
//   bool _isNewNote = true;

//   @override
//   void initState() {
//     super.initState();
//     _quillController = QuillController.basic();

//     if (widget.note != null) {
//       _isNewNote = false;
//       widget.noteId = widget.note!['id'];
//       _titleController.text = widget.note!['title'];
//       _isStarred = widget.note!['starred'] == 1;
//       _isLocked = widget.note!['locked'] == 1;

//       try {
//         String noteContent = widget.note!['content'];

//         // Ensure content is in JSON format
//         dynamic decodedContent;
//         try {
//           decodedContent = jsonDecode(noteContent);
//         } catch (e) {
//           // If decoding fails, assume it's plain text and convert
//           decodedContent = [
//             {"insert": "$noteContent\n"}
//           ];
//         }

//         _quillController = QuillController(
//           document: Document.fromJson(decodedContent),
//           selection: TextSelection.collapsed(offset: 0),
//         );
//       } catch (e) {
//         print("Error loading note: $e");
//       }
//     }

//     setState(() => _isLoading = false);
//   }

//   Future<void> _createNote() async {
//     String title = _titleController.text.trim();
//     String contentJson =
//         jsonEncode(_quillController.document.toDelta().toJson());

//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Title cannot be empty"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (!_isNewNote) return;

//     int noteId = await DatabaseHelper().addNote(title, contentJson);
//     setState(() {
//       widget.noteId = noteId;
//       _isNewNote = false;
//     });

//     widget.onSave();
//   }

//   Future<void> _updateNote() async {
//     if (_isNewNote || widget.noteId == null) return;

//     String title = _titleController.text.trim();
//     String contentJson =
//         jsonEncode(_quillController.document.toDelta().toJson());

//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Title cannot be empty"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     await DatabaseHelper().updateNote(widget.noteId!, title, contentJson);
//     widget.onSave();
//   }

//   Future<void> _saveNote() async {
//     if (_isNewNote) {
//       await _createNote();
//     } else {
//       await _updateNote();
//     }
//   }

//   Future<bool> _onBackPressed() async {
//     await _saveNote();
//     return Future.value(true);
//   }

//   void _toggleStarred() {
//     setState(() {
//       _isStarred = !_isStarred;
//     });
//     _saveNote();
//   }

//   void _lockNote() async {
//     if (widget.note != null) {
//       showLockNotesDialog(
//         context,
//         widget.note!['id'],
//         () {
//           setState(() {
//             _isLocked = true;
//           });
//           widget.onSave();
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onBackPressed,
//       child: Scaffold(
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: Colors.black),
//           title: Text(
//             _isNewNote ? 'New Note' : 'Edit Note',
//             style: TextFontStyle.textStylec17c000000Poppins400,
//           ),
//           actions: [
//             // IconButton(icon: Icon(Icons.save), onPressed: _saveNote),
//             PopupMenuButton<String>(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16.r)),
//               onSelected: (String value) {
//                 if (value == "starred") {
//                   _toggleStarred();
//                 }
//               },
//               itemBuilder: (BuildContext context) => [
//                 PopupMenuItem(
//                   value: "starred",
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           _isStarred ? Icons.star : Icons.star_border,
//                           color: _isStarred ? Colors.amber : Colors.black,
//                         ),
//                         onPressed: () {
//                           _toggleStarred();
//                           NavigationService.goBack();
//                         },
//                       ),
//                       SizedBox(width: 10),
//                       Text("Starred"),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: "lock",
//                   child: Row(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 10.w),
//                         child: Icon(Icons.lock, color: Colors.black),
//                       ),
//                       SizedBox(width: 10.w),
//                       Text("Lock"),
//                     ],
//                   ),
//                   onTap: () {
//                     if (widget.note != null) {
//                       showLockNotesDialog(
//                         context,
//                         widget.note!['id'],
//                         () {
//                           setState(() {});
//                         },
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: _titleController,
//                           decoration: InputDecoration(
//                               hintText: 'Title',
//                               border: InputBorder.none,
//                               hintStyle: TextStyle(
//                                   fontSize: 16.sp, color: Colors.grey)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: QuillEditor.basic(
//                       controller: _quillController,
//                       configurations: QuillEditorConfigurations(
//                         placeholder: 'Write your note.....',
//                         customStyleBuilder: (attribute) =>
//                             TextStyle(fontSize: 16.sp),
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                       ),
//                     ),
//                   ),
//                   QuillToolbar.simple(
//                       controller: _quillController,
//                       configurations: QuillSimpleToolbarConfigurations(
//                           multiRowsDisplay: false)),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notely/constants/text_font_style.dart';
import 'package:notely/features/lock_notes/presentation/widget/show_lock_dialog.dart';
import 'package:notely/helpers/navigation_service.dart';
import '../../../../constants/app_constants.dart';
import '../../../../helpers/di.dart';
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
  final _titleController = TextEditingController();
  late QuillController _quillController;
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

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Title cannot be empty"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_isNewNote) {
      int noteId = await DatabaseHelper().addNote(title, contentJson);
      setState(() {
        widget.noteId = noteId;
        _isNewNote = false;
      });
    } else {
      await DatabaseHelper().updateNote(widget.noteId!, title, contentJson);
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
    setState(() => _isStarred = !_isStarred);
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
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle:
                            TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _quillController,
                      configurations: QuillEditorConfigurations(
                        placeholder: 'Write your note.....',
                        customStyleBuilder: (attribute) =>
                            TextStyle(fontSize: 16.sp),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
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
