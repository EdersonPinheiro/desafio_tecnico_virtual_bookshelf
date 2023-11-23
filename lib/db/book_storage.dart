import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/book_model.dart';

class BookStorage {
  BookStorage._privateConstructor();
  static final BookStorage instance = BookStorage._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'favorite_books.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE favorite_books(
            id INTEGER PRIMARY KEY,
            title TEXT,
            author TEXT,
            cover_url TEXT,
            download_url TEXT,
            marker TEXT
          )
          ''',
        );
      },
    );
  }

  Future<void> insertFavoriteBook(BookModel book) async {
    final db = await database;
    await db.insert('favorite_books', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFavoriteBook(int id) async {
    final db = await database;
    await db.delete(
      'favorite_books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BookModel>> getFavoriteBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite_books');

    return List.generate(maps.length, (i) {
      dynamic markerValue = maps[i]['marker'];
      bool marker;

      if (markerValue is bool) {
        marker = markerValue;
      } else {
        
        marker =
            false;
      }

      return BookModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        author: maps[i]['author'],
        cover_url: maps[i]['cover_url'],
        download_url: maps[i]['download_url'],
        marker: marker,
      );
    });
  }
}
