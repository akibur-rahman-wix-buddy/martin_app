// import 'package:flutter/material.dart';
// import 'package:martin_app/features/database/db_helper.dart';
// import '../../../gen/colors.gen.dart';
// import '../../../helpers/all_routes.dart';
// import '../../../helpers/navigation_service.dart';

// class CustomDrawer extends StatefulWidget {
//   const CustomDrawer({super.key});

//   @override
//   State<CustomDrawer> createState() => _CustomDrawerState();
// }

// List<Map<String, dynamic>> _notes = [];
// List<Map<String, dynamic>> _recycleBinNotes = [];
// List<Map<String, dynamic>> _starredNotes = [];

// class _CustomDrawerState extends State<CustomDrawer> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();

//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _loadRecycleBinNotes();
//     _starredAllNotes();
//   }

//   Future<void> _loadNotes() async {
//     var notes = await _dbHelper.getActiveNotes();
//     setState(() {
//       _notes = notes;
//     });
//   }

//   Future<void> _loadRecycleBinNotes() async {
//     var recycleBinNotes = await _dbHelper.getRecycleBinNotes();
//     setState(() {
//       _recycleBinNotes = recycleBinNotes;
//     });
//   }

//   Future<void> _starredAllNotes() async {
//     var starredAllNotes = await _dbHelper.getStarredNotes();
//     setState(() {
//       _starredNotes = starredAllNotes;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blueAccent,
//             ),
//             child: Center(
//               child: Text(
//                 'Martin',
//                 style: TextStyle(
//                   color: AppColors.cFFFFFF,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.note),
//             title: Text('All Notes'),
//             trailing: Text('${_notes.length}'),
//             onTap: () {
//               NavigationService.navigateTo(Routes.homeScreen);
//               setState(() {});
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.delete),
//             title: Text('Recycle Bin'),
//             onTap: () {
//               NavigationService.navigateTo(Routes.recycleBinScreen);
//               setState(() {});
//             },
//             trailing: Text('${_recycleBinNotes.length}'),
//           ),
//           ListTile(
//             leading: Icon(Icons.star),
//             title: Text('Starred'),
//             trailing: Text('${_starredNotes.length}'),
//             onTap: () {
//               NavigationService.navigateTo(Routes.starredScreen);
//               setState(() {});
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.lock),
//             title: Text('Lock Feature'),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
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

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadRecycleBinNotes();
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

  Future<void> _starredAllNotes() async {
    var starredAllNotes = await _dbHelper.getStarredNotes();
    setState(() {
      _starredNotes = starredAllNotes;
    });
  }

  // Function to pick a .txt file
  Future<void> _pickAndUploadTxtFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString(); // Read file content

      if (content.isNotEmpty) {
        await _dbHelper.addNote("Uploaded Note", content);
        _loadNotes(); // Refresh notes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
      }
    } else {
      // User canceled file selection
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
                'Martin',
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
              Navigator.pop(context);
            },
          ),
          Divider(), // Add a separator
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('Upload .txt File'),
            onTap: _pickAndUploadTxtFile,
          ),
        ],
      ),
    );
  }
}
