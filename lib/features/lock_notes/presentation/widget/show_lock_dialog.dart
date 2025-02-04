import 'package:flutter/material.dart';
import 'package:martin_app/common_widgets/custom_textfeild.dart';
import 'package:martin_app/helpers/ui_helpers.dart';

void showLockNotesDialog(BuildContext context, VoidCallback onDelete) {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Lock Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to lock your notes?'),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String password = passwordController.text;
              String confirmPassword = confirmPasswordController.text;

              if (password.isNotEmpty && password == confirmPassword) {
                onDelete();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match!')),
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
