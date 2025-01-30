// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../../home/presentation/database/db_helper.dart';

// class RecycleBinScreen extends StatefulWidget {
//   @override
//   _RecycleBinScreenState createState() => _RecycleBinScreenState();
// }

// class _RecycleBinScreenState extends State<RecycleBinScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   List<Map<String, dynamic>> _recycleBinNotes = [];
//   Set<int> _selectedNotes = Set<int>();

//   @override
//   void initState() {
//     super.initState();
//     _fetchRecycleBinNotes();
//   }

//   void _fetchRecycleBinNotes() async {
//     final notes = await DatabaseHelper().getRecycleBinNotes();
//     setState(() {
//       _recycleBinNotes = notes;
//     });
//   }

//   void _restoreSelectedNotes() async {
//     for (var id in _selectedNotes) {
//       await DatabaseHelper().restoreNoteFromRecycleBin(id);
//     }
//     setState(() {
//       _selectedNotes.clear();
//     });
//     _fetchRecycleBinNotes();
//   }

//   void _permanentlyDeleteSelectedNotes() async {
//     for (var id in _selectedNotes) {
//       await DatabaseHelper().permanentlyDeleteNote(id);
//     }
//     setState(() {
//       _selectedNotes.clear();
//     });
//     _fetchRecycleBinNotes();
//   }

//   void _toggleNoteSelection(int noteId) {
//     setState(() {
//       if (_selectedNotes.contains(noteId)) {
//         _selectedNotes.remove(noteId);
//       } else {
//         _selectedNotes.add(noteId);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: Icon(Icons.menu),
//           onPressed: () {
//             // Open the Drawer when the menu button is pressed
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         ),
//         title: Text(
//           _selectedNotes.isEmpty
//               ? 'Recycle Bin'
//               : '${_selectedNotes.length} Selected',
//         ),
//         actions: [
//           if (_selectedNotes.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.restore, color: Colors.green),
//               onPressed: _restoreSelectedNotes,
//             ),
//           if (_selectedNotes.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.delete_forever, color: Colors.red),
//               onPressed: _permanentlyDeleteSelectedNotes,
//             ),
//         ],
//       ),
//       body: GridView.builder(
//         padding: EdgeInsets.all(12),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//         ),
//         itemCount: _recycleBinNotes.length,
//         itemBuilder: (context, index) {
//           final note = _recycleBinNotes[index];
//           final isSelected = _selectedNotes.contains(note['id']);

//           return GestureDetector(
//             onLongPress: () => _toggleNoteSelection(note['id']),
//             onTap: () {
//               if (_selectedNotes.isNotEmpty) {
//                 _toggleNoteSelection(note['id']);
//               }
//             },
//             child: Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.red[100] : Colors.white,
//                 border: Border.all(
//                   color: isSelected ? Colors.red : Colors.grey[300]!,
//                   width: 2,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     note['content'] ?? 'No Content',
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Spacer(),
//                   Text(
//                     note['createAt'] != null
//                         ? DateFormat('MMM dd, yyyy h:mm a')
//                             .format(DateTime.parse(note['createAt']))
//                         : 'No Date',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:martin_app/features/custom_drawer/presentation/custom_drawer.dart';

import '../../database/db_helper.dart';

class RecycleBinScreen extends StatefulWidget {
  @override
  _RecycleBinScreenState createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _recycleBinNotes = [];
  Set<int> _selectedNotes = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchRecycleBinNotes();
  }

  void _fetchRecycleBinNotes() async {
    final notes = await DatabaseHelper().getRecycleBinNotes();
    setState(() {
      _recycleBinNotes = notes;
    });
  }

  void _restoreSelectedNotes() async {
    for (var id in _selectedNotes) {
      await DatabaseHelper().restoreNoteFromRecycleBin(id);
    }
    setState(() {
      _selectedNotes.clear();
    });
    _fetchRecycleBinNotes();
  }

  void _permanentlyDeleteSelectedNotes() async {
    for (var id in _selectedNotes) {
      await DatabaseHelper().permanentlyDeleteNote(id);
    }
    setState(() {
      _selectedNotes.clear();
    });
    _fetchRecycleBinNotes();
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNotes.contains(noteId)) {
        _selectedNotes.remove(noteId);
      } else {
        _selectedNotes.add(noteId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
            _selectedNotes.isEmpty
                ? 'Recycle Bin'
                : '${_selectedNotes.length} Selected',
            style: TextStyle(color: Colors.black)),
        actions: [
          if (_selectedNotes.isNotEmpty)
            InkWell(
                onTap: _restoreSelectedNotes,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text('Restore',
                      style: TextStyle(color: Colors.black, fontSize: 16.sp)),
                )),
          if (_selectedNotes.isNotEmpty)
            InkWell(
                onTap: _permanentlyDeleteSelectedNotes,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                  child: Text('Delete',
                      style: TextStyle(color: Colors.black, fontSize: 16.sp)),
                )),
        ],
      ),
      drawer: CustomDrawer(),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _recycleBinNotes.length,
        itemBuilder: (context, index) {
          final note = _recycleBinNotes[index];
          final isSelected = _selectedNotes.contains(note['id']);

          return GestureDetector(
            onLongPress: () => _toggleNoteSelection(note['id']),
            onTap: () {
              if (_selectedNotes.isNotEmpty) {
                _toggleNoteSelection(note['id']);
              }
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red[100] : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['content'] ?? 'No Content',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Text(
                    note['createAt'] != null
                        ? DateFormat('MMM dd, yyyy h:mm a')
                            .format(DateTime.parse(note['createAt']))
                        : 'No Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
