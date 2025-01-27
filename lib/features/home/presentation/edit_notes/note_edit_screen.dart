import 'package:flutter/material.dart';
import 'package:martin_app/constants/text_font_style.dart';
import '../database/db_helper.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      return; // Prevent saving empty notes.
    }

    if (widget.note == null) {
      await DatabaseHelper().addNote(title, content);
    } else {
      await DatabaseHelper().updateNote(widget.note!['id'], title, content);
    }

    widget.onSave();
  }

  Future<bool> _onBackPressed() async {
    await _saveNote();
    Navigator.pop(context);
    return Future.value(false);
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
            // IconButton(
            //   icon: Icon(
            //     Icons.save,
            //     color: Colors.red,
            //   ),
            //   onPressed: () {
            //     _saveNote();
            //     Navigator.pop(context);
            //   },
            // ),
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
