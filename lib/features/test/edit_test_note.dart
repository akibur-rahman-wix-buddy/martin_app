import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../database/db_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final int? noteId;

  NoteEditorScreen({this.noteId});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  bool _isLoading = true; // Loading state for UI

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    if (widget.noteId != null) {
      _loadNote();
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
      // Add new note if no noteId is provided
      await DatabaseHelper().addNote(title, contentJson);
    } else {
      // Update existing note if noteId is provided
      await DatabaseHelper().updateNote(widget.noteId!, title, contentJson);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Enter title",
                      border: OutlineInputBorder(),
                    ),
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
    );
  }
}
