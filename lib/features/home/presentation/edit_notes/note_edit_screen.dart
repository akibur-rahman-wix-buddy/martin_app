import 'package:flutter/material.dart';
import 'package:martin_app/constants/text_font_style.dart';
import 'package:martin_app/features/lock_notes/presentation/widget/show_lock_dialog.dart';
import 'package:martin_app/helpers/navigation_service.dart';

import '../../../database/db_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  final VoidCallback onSave;

  NoteEditorScreen({this.note, required this.onSave});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isStarred = false;
  bool _isLocked = false;

  void _toggleStarred() {
    setState(() {
      _isStarred = !_isStarred;
    });
    _saveNote();
  }

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
      _isStarred = widget.note!['starred'] == 1;
      _isLocked = widget.note!['locked'] == 1;
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    if (widget.note == null) {
      await DatabaseHelper().addNote(title, content, starred: _isStarred);
    } else {
      await DatabaseHelper()
          .updateNote(widget.note!['id'], title, content, starred: _isStarred);
    }

    widget.onSave();
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
                      Icon(Icons.lock, color: Colors.black),
                      SizedBox(width: 10),
                      Text("Lock"),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Write your note here...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
