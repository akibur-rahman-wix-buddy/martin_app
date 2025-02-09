import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:martin_app/constants/text_font_style.dart';
import 'package:martin_app/features/lock_notes/presentation/widget/show_lock_dialog.dart';
import 'package:martin_app/helpers/navigation_service.dart';
import '../../../database/db_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  final VoidCallback onSave;
  final int? noteId;

  NoteEditorScreen({this.note, required this.onSave, this.noteId});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  late QuillController _quillController;
  bool _isLoading = true; // Loading state for UI
  bool _isStarred = false;
  bool _isLocked = false;

  void _toggleStarred() {
    setState(() {
      _isStarred = !_isStarred;
    });
    _saveNote();
  }

  void _toggleLocked() {
    setState(() {
      _isLocked = !_isLocked;
    });
    widget.onSave();
  }

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    if (widget.note != null) {
      _loadNote();
      _titleController.text = widget.note!['title'];
      _isStarred = widget.note!['starred'] == 1;
      _isLocked = widget.note!['locked'] == 1;
      try {
        _quillController = QuillController(
          document: Document.fromJson(jsonDecode(widget.note!['content'])),
          selection: TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        print("Error loading note: $e");
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Load the existing note from the database
  Future<void> _loadNote() async {
    List<Map<String, dynamic>> notes = await DatabaseHelper().getNotes();
    Map<String, dynamic>? note = notes.firstWhere(
      (n) => n['id'] == widget.noteId,
      orElse: () => {},
    );

    if (note.isNotEmpty) {
      _titleController.text = note['title'];
      try {
        _quillController = QuillController(
          document: Document.fromJson(jsonDecode(note['content'])),
          selection: TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        print("Error loading note: $e");
      }
    }

    setState(() => _isLoading = false);
  }

  // Save the note (insert or update)
  Future<void> _saveNote() async {
    String title = _titleController.text.trim();
    String contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Title cannot be empty"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (widget.noteId == null) {
      await DatabaseHelper().addNote(title, contentJson);
    } else {
      await DatabaseHelper().updateNote(widget.noteId!, title, contentJson);
    }

    Navigator.pop(context, true);
  }

  Future<bool> _onBackPressed() async {
    await _saveNote();
    Navigator.pop(context);
    return Future.value(false);
  }

  void _lockNote() async {
    if (widget.note != null) {
      showLockNotesDialog(
        context,
        widget.note!['id'],
        () {
          setState(() {
            _isLocked = true;
          });
          widget.onSave();
        },
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
            widget.note == null ? 'New Note' : 'Edit Note',
            style: TextFontStyle.textStylec17c000000Poppins400,
          ),
          actions: [
            IconButton(icon: Icon(Icons.save), onPressed: _saveNote),
            PopupMenuButton<String>(
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
                      IconButton(
                        icon: Icon(
                          _isStarred ? Icons.star : Icons.star_border,
                          color: _isStarred ? Colors.amber : Colors.black,
                        ),
                        onPressed: () {
                          _toggleStarred();
                          NavigationService.goBack;
                        }, // Toggle star when clicked
                      ),
                      SizedBox(width: 10),
                      Text("Starred"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "lock",
                  child: Row(
                    children: [
                      Icon(_isLocked ? Icons.lock : Icons.lock_open,
                          color: Colors.black),
                      SizedBox(width: 10),
                      Text(_isLocked ? "Unlock" : "Lock"),
                    ],
                  ),
                  onTap: () {
                    if (widget.note != null) {
                      showLockNotesDialog(
                        context,
                        widget.note!['id'],
                        () {
                          setState(() {}); // Refresh UI after locking
                        },
                      );
                    }
                  },
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
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _quillController,
                    ),
                  ),
                  QuillToolbar.simple(controller: _quillController),
                ],
              ),
      ),
    );
  }
}
