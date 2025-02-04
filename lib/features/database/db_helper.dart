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
    return openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          createAt TEXT,
          isDeleted INTEGER DEFAULT 0,
          deletedAt TEXT,
          starred INTEGER DEFAULT 0,
          isLocked INTEGER DEFAULT 0,
          password TEXT
    )''');
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return db.query('notes', orderBy: 'createAt DESC');
  }

  Future<int> addNote(String title, String content,
      {bool starred = false}) async {
    final db = await database;
    return db.insert('notes', {
      'title': title,
      'content': content,
      'createAt': DateTime.now().toIso8601String(),
      'starred': starred ? 1 : 0,
    });
  }

  Future<int> updateNote(int id, String title, String content,
      {bool starred = false}) async {
    final db = await database;
    return db.update(
      'notes',
      {'title': title, 'content': content, 'starred': starred ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Future<void> moveToRecycleBin(int noteId) async {
  //   final db = await database;
  //   await db.update(
  //     'notes',
  //     {'isDeleted': 1},
  //     where: 'id = ?',
  //     whereArgs: [noteId],
  //   );
  // }

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

  Future<void> restoreNoteFromRecycleBin(int noteId) async {
    final db = await database;
    await db.update(
      'notes',
      {'isDeleted': 0},
      where: 'id = ?',
      whereArgs: [noteId],
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
      'notes',
      where: 'isDeleted = ?',
      whereArgs: [0],
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

  // Add a recent search query to the database
  Future<void> addSearchQuery(String query) async {
    final db = await database;
    await db.insert('recent_searches', {
      'query': query,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

// Get the recent search queries, ordered by timestamp (most recent first)
  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final result = await db.query(
      'recent_searches',
      orderBy: 'timestamp DESC',
      limit: 5, // Limit to the latest 5 searches
    );
    return result.map((row) => row['query'] as String).toList();
  }

// Clear all recent search queries
  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }

  // Fetch only starred notes
  Future<List<Map<String, dynamic>>> getStarredNotes() async {
    final db = await database;
    return db.query(
      'notes',
      where: 'starred = ? AND isDeleted = ?',
      whereArgs: [1, 0], // Only starred and not deleted notes
      orderBy: 'createAt DESC',
    );
  }

  Future<void> toggleFavouriteStatus(int noteId, bool isFavourite) async {
    final db = await database;
    await db.update(
      'notes',
      {'starred': isFavourite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  //lock database
  // Future<void> lockNote(int noteId, String password) async {
  //   final db = await database;
  //   await db.update(
  //     'notes',
  //     {'isLocked': 1, 'password': password},
  //     where: 'id = ?',
  //     whereArgs: [noteId],
  //   );
  // }

  // Future<bool> unlockNote(int noteId, String enteredPassword) async {
  //   final db = await database;
  //   final result = await db.query(
  //     'notes',
  //     columns: ['password'],
  //     where: 'id = ?',
  //     whereArgs: [noteId],
  //     limit: 1,
  //   );

  //   if (result.isNotEmpty && result.first['password'] == enteredPassword) {
  //     await db.update(
  //       'notes',
  //       {'isLocked': 0, 'password': null},
  //       where: 'id = ?',
  //       whereArgs: [noteId],
  //     );
  //     return true;
  //   }
  //   return false;
  // }

  // Future<List<Map<String, dynamic>>> getLockedNotes() async {
  //   final db = await database;
  //   return db.query(
  //     'notes',
  //     where: 'isLocked = ?',
  //     whereArgs: [1],
  //   );
  // }

  Future<void> lockNote(int noteId, String password) async {
    final db = await database;
    await db.update(
      'notes',
      {'isLocked': 1, 'password': password},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<void> unlockNote(int id) async {
    final db = await database;
    await db.update(
      'notes',
      {'isLocked': 0, 'password': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getLockedNotes() async {
    final db = await database;
    return await db.query('notes', where: 'isLocked = ?', whereArgs: [1]);
  }
}
