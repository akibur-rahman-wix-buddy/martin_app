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

List<Map<String, dynamic>> _notes = [];
List<Map<String, dynamic>> _recycleBinNotes = [];

class _CustomDrawerState extends State<CustomDrawer> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadRecycleBinNotes();
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: AppColors.cFFFFFF,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.note),
            title: Text('All Notes'),
            trailing: Text('${_notes.length}'),
            onTap: () {
              NavigationService.navigateTo(Routes.homeScreen);
              setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Recycle Bin'),
            onTap: () {
              NavigationService.navigateTo(Routes.recycleBinScreen);
              setState(() {});
            },
            trailing: Text('${_recycleBinNotes.length}'),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Starred'),
            onTap: () {
              NavigationService.navigateTo(Routes.starredScreen);
              setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Lock Feature'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
