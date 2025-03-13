import 'package:flutter/material.dart';
import '../../../../common_widgets/custom_textfeild.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../database/db_helper.dart';

void showLockNotesDialog(
    BuildContext context, int noteId, VoidCallback onLock) {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Lock Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a password to lock this note'),
            UIHelper.verticalSpaceSmall,
            CustomTextFormField(
              controller: passwordController,
              hintText: 'Enter password',
            ),
            UIHelper.verticalSpaceSmall,
            CustomTextFormField(
              controller: confirmPasswordController,
              hintText: 'Confirm password',
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
              if (passwordController.text == confirmPasswordController.text &&
                  passwordController.text.isNotEmpty) {
                await DatabaseHelper()
                    .lockNote(noteId, passwordController.text);
                onLock(); // Refresh UI after locking
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match!')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

void showLockLocal(BuildContext context, Function(String) onLock) {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Lock Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a password to lock this note'),
            UIHelper.verticalSpaceSmall,
            CustomTextFormField(
              controller: passwordController,
              hintText: 'Enter password',
            ),
            UIHelper.verticalSpaceSmall,
            CustomTextFormField(
              controller: confirmPasswordController,
              hintText: 'Confirm password',
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
              if (passwordController.text == confirmPasswordController.text &&
                  passwordController.text.isNotEmpty) {
                onLock(
                    confirmPasswordController.text); // Refresh UI after locking
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match!')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}
