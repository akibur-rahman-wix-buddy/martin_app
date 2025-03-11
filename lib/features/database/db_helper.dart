// import 'dart:developer';

// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   DatabaseHelper._();
//   static final DatabaseHelper _instance = DatabaseHelper._();
//   static Database? _database;
//   factory DatabaseHelper() => _instance;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'my_database');

//     return openDatabase(
//       path,
//       version: 2, // Increase the version for upgrades
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE notes (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT,
//             content TEXT,
//             createAt TEXT,
//             isDeleted INTEGER DEFAULT 0,
//             deletedAt TEXT,
//             starred INTEGER DEFAULT 0,
//             isLocked INTEGER DEFAULT 0,
//             password TEXT

//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE recent_searches (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             query TEXT NOT NULL,
//             timestamp INTEGER NOT NULL
//           )
//         ''');
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute('''
//             CREATE TABLE IF NOT EXISTS recent_searches (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               query TEXT NOT NULL,
//               timestamp INTEGER NOT NULL
//             )
//           ''');
//         }
//       },
//     );
//   }

//   Future<List<Map<String, dynamic>>> getNotes() async {
//     final db = await database;
//     return db.query(
//       'notes',
//       orderBy: 'updatedAt ASC, createdAt ASC',
//     );
//   }

//   Future<int> addNote(String title, String content,
//       {bool starred = false}) async {
//     final db = await database;
//     return db.insert(
//       'notes',
//       {
//         'title': title,
//         'content': content,
//         'createAt': DateTime.now().toIso8601String(),
//         'starred': starred ? 1 : 0,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<int> updateNote(int id, String title, String content,
//       {bool starred = false}) async {
//     final db = await database;
//     return db.update(
//       'notes',
//       {
//         'title': title,
//         'content': content,
//         'starred': starred ? 1 : 0,
//         'createAt': DateTime.now().toIso8601String(),
//       },
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> deleteNote(int id) async {
//     final db = await database;
//     return db.delete('notes', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<void> moveToRecycleBin(int noteId) async {
//     final db = await database;
//     await db.update(
//       'notes',
//       {
//         'isDeleted': 1,
//         'deletedAt': DateTime.now().toIso8601String(),
//       },
//       where: 'id = ?',
//       whereArgs: [noteId],
//     );
//   }

// Future<void> deleteOldNotes() async {
//   final db = await database;
//   final now = DateTime.now();
//   final thirtyDaysAgo = now.subtract(Duration(days: 30)).toIso8601String();

//   await db.delete(
//     'notes',
//     where: 'isDeleted = 1 AND deletedAt <= ?',
//     whereArgs: [thirtyDaysAgo],
//   );
// }

//   Future<void> restoreNoteFromRecycleBin(int noteId) async {
//     final db = await database;
//     await db.update(
//       'notes',
//       {'isDeleted': 0},
//       where: 'id = ?',
//       whereArgs: [noteId],
//     );
//   }

// Future<void> permanentlyDeleteNote(int noteId) async {
//   final db = await database;
//   await db.delete(
//     'notes',
//     where: 'id = ?',
//     whereArgs: [noteId],
//   );
// }

// Future<List<Map<String, dynamic>>> getActiveNotes() async {
//   final db = await database;
//   return db.query(
//     orderBy: 'createAt DESC',
//     'notes',
//     where: 'isDeleted = ? AND  isLocked = ?',
//     whereArgs: [0, 0],
//   );
// }

// Future<List<Map<String, dynamic>>> getRecycleBinNotes() async {
//   final db = await database;
//   return db.query(
//     'notes',
//     where: 'isDeleted = ?',
//     whereArgs: [1],
//   );
// }

//   Future<void> addSearchQuery(String query) async {
//     final db = await database;
//     await db.insert(
//       'recent_searches',
//       {
//         'query': query,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<String>> getRecentSearches() async {
//     final db = await database;
//     final result = await db.query(
//       'recent_searches',
//       orderBy: 'timestamp DESC',
//       limit: 5,
//     );
//     return result.map((row) => row['query'] as String).toList();
//   }

//   Future<void> clearRecentSearches() async {
//     final db = await database;
//     await db.delete('recent_searches');
//   }

//   Future<List<Map<String, dynamic>>> getStarredNotes() async {
//     final db = await database;
//     return db.query(
//       'notes',
//       where: 'starred = ? AND isDeleted = ?',
//       whereArgs: [1, 0],
//       orderBy: 'createAt DESC',
//     );
//   }

// Future<void> toggleFavouriteStatus(int noteId, bool isFavourite) async {
//   final db = await database;
//   await db.update(
//     'notes',
//     {'starred': 1},
//     where: 'id = ?',
//     whereArgs: [noteId],
//   );
// }

//   Future<void> lockNote(int noteId, String password) async {
//     final db = await database;
//     await db.update(
//       'notes',
//       {'isLocked': 1, 'password': password},
//       where: 'id = ?',
//       whereArgs: [noteId],
//     );
//   }

//   Future<void> unlockNote(int id) async {
//     final db = await database;
//     await db.update(
//       'notes',
//       {'isLocked': 0, 'password': null},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<List<Map<String, dynamic>>> getLockedNotes() async {
//     final db = await database;
//     return await db.query('notes', where: 'isLocked = ?', whereArgs: [1]);
//   }

//   Future<void> updateNoteLockStatus(int noteId, int locked) async {
//     final db = await database;
//     await db.update(
//       'notes',
//       {'locked': locked},
//       where: 'id = ?',
//       whereArgs: [noteId],
//     );
//   }

//   // Debugging: Check if a table exists
//   Future<bool> tableExists(String tableName) async {
//     final db = await database;
//     var result = await db.rawQuery(
//       "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
//       [tableName],
//     );
//     return result.isNotEmpty;
//   }

//   // Call this function before querying `recent_searches`
//   Future<void> checkDatabase() async {
//     bool exists = await tableExists('recent_searches');
//     print('Recent Searches Table Exists: $exists');
//   }

//   Future<int> getTotalNotesCount() async {
//     final db = await database;
//     final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
//     return Sqflite.firstIntValue(result) ?? 0;
//   }

//   // Future<int> getEditedNotesCount() async {
//   //   final db = await database;
//   //   final result = await db
//   //       .rawQuery('SELECT COUNT(*) as count FROM notes WHERE is_edited = 1');
//   //   return Sqflite.firstIntValue(result) ?? 0;
//   // }
// }

import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database');

    return openDatabase(path, version: 2, // Increase the version for upgrades
        onCreate: (db, version) async {
      await db.execute('PRAGMA foreign_keys = ON;');
      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          createAt TEXT,
          isDeleted INTEGER DEFAULT 0,
          deletedAt TEXT,
          starred INTEGER DEFAULT 0,
          isLocked INTEGER DEFAULT 0,
          password TEXT
          
        )
      ''');

      await db.execute('''
        CREATE TABLE recent_searches (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');

      // Add the photos table creation
      await db.execute('''
        CREATE TABLE photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          path TEXT NOT NULL,
          note_id INTEGER,
          FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS recent_searches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      }
    });
  }

  // 📌 Get all notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return db.query('notes', orderBy: 'createAt DESC');
  }

  // 📌 Add a new note
  Future<int> addNote(String title, String content,
      {bool starred = false}) async {
    final db = await database;
    return db.insert(
      'notes',
      {
        'title': title,
        'content': content,
        'createAt': DateTime.now().toIso8601String(),
        'starred': starred ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 📌 Update a note
  Future<int> updateNote(int id, String title, String content,
      {bool starred = false}) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'title': title,
        'content': content,
        'starred': starred ? 1 : 0,
        'createAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 📌 Delete a note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // 📌 Move note to recycle bin
  Future<void> moveToRecycleBin(int noteId) async {
    final db = await database;
    await db.update(
      'notes',
      {
        'isDeleted': 1,
        'deletedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // 📌 Restore a deleted note
  Future<void> restoreNoteFromRecycleBin(int noteId) async {
    final db = await database;
    await db.update(
      'notes',
      {'isDeleted': 0},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // 📌 Get all starred notes
  Future<List<Map<String, dynamic>>> getStarredNotes() async {
    final db = await database;
    return db.query(
      'notes',
      where: 'starred = ? AND isDeleted = ?',
      whereArgs: [1, 0],
      orderBy: 'createAt DESC',
    );
  }

  // 📌 Add search query
  Future<void> addSearchQuery(String query) async {
    final db = await database;
    await db.insert(
      'recent_searches',
      {
        'query': query,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 📌 Get recent searches
  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final result =
        await db.query('recent_searches', orderBy: 'timestamp DESC', limit: 5);
    return result.map((row) => row['query'] as String).toList();
  }

  // 📌 Clear recent searches
  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }

  // 📌 Lock a note
  Future<void> lockNote(int noteId, String password) async {
    final db = await database;
    await db.update(
      'notes',
      {'isLocked': 1, 'password': password},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // 📌 Unlock a note
  Future<void> unlockNote(int id) async {
    final db = await database;
    await db.update(
      'notes',
      {'isLocked': 0, 'password': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 📌 Get all locked notes
  Future<List<Map<String, dynamic>>> getLockedNotes() async {
    final db = await database;
    return db.query('notes', where: 'isLocked = ?', whereArgs: [1]);
  }

  // 📌 Get total number of notes
  Future<int> getTotalNotesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =========================== 🌙 Theme Mode Methods ===========================

  // 📌 Set theme mode (0 = Light, 1 = Dark)
  Future<void> setThemeMode(int mode) async {
    final db = await database;
    await db.update(
      'settings',
      {'theme_mode': mode},
      where: 'id = 1',
    );
  }

  // 📌 Get theme mode
  Future<int> getThemeMode() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = 1');
    if (result.isNotEmpty) {
      return result.first['theme_mode'] as int;
    }
    return 0; // Default Light Mode
  }

  // Debugging: Check if a table exists
  Future<bool> tableExists(String tableName) async {
    final db = await database;
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  Future<void> deleteOldNotes() async {
    final db = await database;
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30)).toIso8601String();

    await db.delete(
      'notes',
      where: 'isDeleted = 1 AND deletedAt <= ?',
      whereArgs: [thirtyDaysAgo],
    );
  }

  Future<List<Map<String, dynamic>>> getRecycleBinNotes() async {
    final db = await database;
    return db.query(
      'notes',
      where: 'isDeleted = ?',
      whereArgs: [1],
    );
  }

  Future<void> permanentlyDeleteNote(int noteId) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<List<Map<String, dynamic>>> getActiveNotes() async {
    final db = await database;
    return db.query(
      orderBy: 'createAt DESC',
      'notes',
      where: 'isDeleted = ? AND  isLocked = ?',
      whereArgs: [0, 0],
    );
  }

  Future<void> toggleFavouriteStatus(int noteId, bool isFavourite) async {
    final db = await database;
    await db.update(
      'notes',
      {'starred': 1},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // Future<void> lockNote(int noteId, String password) async {
  //   final db = await database;
  //   await db.update(
  //     'notes',
  //     {'isLocked': 1, 'password': password},
  //     where: 'id = ?',
  //     whereArgs: [noteId],
  //   );
  // }

  // Future<void> unlockNote(int id) async {
  //   final db = await database;
  //   await db.update(
  //     'notes',
  //     {'isLocked': 0, 'password': null},
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<List<Map<String, dynamic>>> getLockedNotes() async {
  //   final db = await database;
  //   return await db.query('notes', where: 'isLocked = ?', whereArgs: [1]);
  // }

  Future<void> updateNoteLockStatus(int noteId, int locked) async {
    final db = await database;
    await db.update(
      'notes',
      {'locked': locked},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // Debugging: Check if a table exists
  // Future<bool> tableExists(String tableName) async {
  //   final db = await database;
  //   var result = await db.rawQuery(
  //     "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
  //     [tableName],
  //   );
  //   return result.isNotEmpty;
  // }

  // Call this function before querying `recent_searches`
  Future<void> checkDatabase() async {
    bool exists = await tableExists('recent_searches');
    print('Recent Searches Table Exists: $exists');
  }

  // Future<int> getTotalNotesCount() async {
  //   final db = await database;
  //   final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
  //   return Sqflite.firstIntValue(result) ?? 0;
  // }

  // Future<int> getEditedNotesCount() async {
  //   final db = await database;
  //   final result = await db
  //       .rawQuery('SELECT COUNT(*) as count FROM notes WHERE is_edited = 1');
  //   return Sqflite.firstIntValue(result) ?? 0;
  // }

  Future<int> insertPhoto(String path, int noteId) async {
    final db = await database;
    return await db.insert(
      'photos',
      {'path': path, 'note_id': noteId},
    );
  }

  Future<List<Map<String, dynamic>>> getPhotos() async {
    final db = await database;
    return await db.query('photos');
  }

  Future<int> deletePhoto(int id) async {
    final db = await database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> filterData(
      {required String filed,
      required int value,
      required String table}) async {
    final db = await database;
    try {
      // Query the database with a filter on measurementType
      final List<Map<String, dynamic>> result = await db.query(
        table,
        where: '$filed = ?',
        whereArgs: [value],
      );

      // Return the filtered data
      return result;
    } catch (e) {
      return [];
    }
  }
}
