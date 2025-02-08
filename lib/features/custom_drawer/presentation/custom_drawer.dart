import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:martin_app/features/database/db_helper.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/navigation_service.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _recycleBinNotes = [];
  List<Map<String, dynamic>> _starredNotes = [];
  List<Map<String, dynamic>> _lockNotes = [];
  List<String> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadRecycleBinNotes();
    _loadLockNotes();
    _starredAllNotes();
  }

  Future<void> _loadNotes() async {
    var notes = await _dbHelper.getActiveNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _loadRecycleBinNotes() async {
    var recycleBinNotes = await _dbHelper.getRecycleBinNotes();
    setState(() {
      _recycleBinNotes = recycleBinNotes;
    });
  }

  Future<void> _loadLockNotes() async {
    var starredAllNotes = await _dbHelper.getStarredNotes();
    setState(() {
      _starredNotes = starredAllNotes;
    });
  }

  Future<void> _starredAllNotes() async {
    var lockAllNotes = await _dbHelper.getLockedNotes();
    setState(() {
      _lockNotes = lockAllNotes;
    });
  }

  Future<void> _pickAndUploadTxtFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: true,
    );

    if (result != null) {
      for (PlatformFile file in result.files) {
        File txtFile = File(file.path!);
        String content = await txtFile.readAsString();
        String fileName = file.name;

        if (content.isNotEmpty) {
          await _dbHelper.addNote(fileName, content);
          _uploadedFiles.add(fileName);
        }
      }

      _loadNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${result.files.length} file(s) uploaded successfully!')),
      );
      NavigationService.navigateTo(Routes.homeScreen);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Center(
              child: Text(
                'Notely',
                style: TextStyle(
                  color: AppColors.cFFFFFF,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.note),
            title: Text('All Notes'),
            trailing: Text('${_notes.length}'),
            onTap: () {
              NavigationService.navigateTo(Routes.homeScreen);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Recycle Bin'),
            trailing: Text('${_recycleBinNotes.length}'),
            onTap: () {
              NavigationService.navigateTo(Routes.recycleBinScreen);
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Starred'),
            trailing: Text('${_starredNotes.length}'),
            onTap: () {
              NavigationService.navigateTo(Routes.starredScreen);
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Lock Feature'),
            onTap: () {
              NavigationService.navigateTo(Routes.lockNotesScreen);
            },
            trailing: Text('${_lockNotes.length}'),
          ),
          Divider(), // Add a separator
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('Upload .txt File'),
            subtitle: _uploadedFiles.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _uploadedFiles
                        .map((fileName) => Text(fileName,
                            style: TextStyle(fontSize: 12, color: Colors.grey)))
                        .toList(),
                  )
                : null,
            onTap: () {
              _pickAndUploadTxtFiles();
              NavigationService.navigateTo(Routes.homeScreen);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
