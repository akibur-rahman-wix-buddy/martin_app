import 'package:flutter/material.dart';

void showPermanentlyDelete(BuildContext context, VoidCallback onDelete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Permanently Delete'),
        content: const Text('Are you sure you want to delete your all notes?'),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Call the delete method
              onDelete();
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}
