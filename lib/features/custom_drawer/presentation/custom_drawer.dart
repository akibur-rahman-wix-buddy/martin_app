import 'package:flutter/material.dart';

import '../../../gen/colors.gen.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/navigation_service.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
            onTap: () {
              NavigationService.goBack;
              NavigationService.navigateTo(Routes.homeScreen);
              // Navigator.pop(context);
              setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Recycle Bin'),
            onTap: () {
              NavigationService.goBack;
              NavigationService.navigateTo(Routes.recycleBinScreen);

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
