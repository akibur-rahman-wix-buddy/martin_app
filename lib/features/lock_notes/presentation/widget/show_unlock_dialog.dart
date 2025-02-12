import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notely/helpers/ui_helpers.dart';
import '../../../database/db_helper.dart';

void showUnlockDialog(BuildContext context, int noteId, String correctPassword,
    VoidCallback onUnlock) {
  TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Unlock Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter password to unlock this note'),
            UIHelper.verticalSpace(4.h),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text == correctPassword) {
                await DatabaseHelper().unlockNote(noteId);
                onUnlock(); // Refresh the locked notes screen
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect password!')),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      );
    },
  );
}
