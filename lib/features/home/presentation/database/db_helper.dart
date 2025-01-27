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
          isDeleted INTEGER DEFAULT 0
    )''');
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return db.query('notes', orderBy: 'createAt DESC');
  }

  Future<int> addNote(String title, String content) async {
    final db = await database;
    return db.insert('notes', {
      'title': title,
      'content': content,
      'createAt': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateNote(int id, String title, String content) async {
    final db = await database;
    return db.update(
      'notes',
      {'title': title, 'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveToRecycleBin(int noteId) async {
    final db = await database;
    await db.update(
      'notes',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [noteId],
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
}
