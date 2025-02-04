import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSaver {
  late String _localPath;
  late bool _permissionReady;

  Future<void> saveFileToDownload(String fileName, String content) async {
    _permissionReady = await _checkPermission();
    if (_permissionReady) {
      await _prepareSaveDir();
      await _saveTxtFile(fileName, content);
    }
  }

  Future<String?> _findLocalPath() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download"; // Downloads folder
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final storagePermission = await Permission.storage.status;

      if (storagePermission.isGranted) {
        return true;
      } else if (await Permission.manageExternalStorage.isGranted) {
        return true; // For Android 11+ with MANAGE_EXTERNAL_STORAGE
      } else {
        final result = await Permission.manageExternalStorage.request();
        return result.isGranted;
      }
    }
    return true; // For iOS or other platforms
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final directory = Directory(_localPath);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> _saveTxtFile(String fileName, String content) async {
    final file = File('$_localPath/$fileName.txt');
    await file.writeAsString(content);
    print("File saved at: ${file.path}");
  }
}
