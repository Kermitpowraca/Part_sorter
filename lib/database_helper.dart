import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();
  final Logger _logger = Logger(); // Dodano instancję loggera
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Map<String, dynamic>?> findBoxByName(String name) async {
    final db = await database;
    final results = await db.query(
      'boxes',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'part_sorter.db');
    _logger.i('Próba otwarcia bazy danych: $path'); // Logowanie ścieżki

    try {
      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      _logger.i('Database opened successfully at $path');
      return db;
    } catch (e) {
      _logger.e('Error opening database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela na pudełka
    await db.execute('''
    CREATE TABLE boxes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      hasCompartments INTEGER NOT NULL,
      compartmentsCount INTEGER,
      width REAL,
      height REAL,
      depth REAL
    )
  ''');

    await db.execute('''
    CREATE TABLE shelf_unit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  shelf_count INTEGER NOT NULL,
  same_shelf INTEGER NOT NULL,
  is_horizontal INTEGER NOT NULL DEFAULT 1 -- 1 = poziome, 0 = pionowe
);

  ''');

    await db.execute('''
    CREATE TABLE shelves (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shelf_unit_id INTEGER NOT NULL,
      shelf_number INTEGER,
      height REAL NOT NULL,
      width REAL NOT NULL,
      depth REAL NOT NULL,
      FOREIGN KEY (shelf_unit_id) REFERENCES shelf_unit(id) ON DELETE CASCADE
    );
  ''');

    // Tabela na wystawy
    await db.execute('''
    CREATE TABLE exhibits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      location TEXT NOT NULL
    )
  ''');
  }

  Future<void> deleteShelvesByShelfUnitId(int shelfUnitId) async {
    final db = await database;
    await db.delete(
      'shelves', // Nazwa tabeli
      where: 'shelf_unit_id = ?', // Warunek usunięcia
      whereArgs: [shelfUnitId], // Argument warunku
    );
  }

  Future<void> insertShelf(
    Database db,
    int shelfUnitId,
    double height,
    double width,
    double depth,
    int shelfNumber,
  ) async {
    await db.insert(
      'shelves',
      {
        'shelf_unit_id': shelfUnitId,
        'height': height,
        'width': width,
        'depth': depth,
        'shelf_number': shelfNumber, // Dodano numer półki
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      _logger.d('Migrating database from $oldVersion to $newVersion...');
    }
  }

  Future<int> insertShelfUnit(Database db, String name, int shelfCount,
      int sameShelf, int isHorizontal) async {
    try {
      // Sprawdzenie, czy regał już istnieje
      final existingShelf = await db.query(
        'shelf_unit',
        where: 'LOWER(TRIM(name)) = ?',
        whereArgs: [name.trim().toLowerCase()],
        limit: 1,
      );

      if (existingShelf.isNotEmpty) {
        _logger.i('Shelf unit already exists: $name');
        return -1; // Kod błędu dla duplikatu
      }

      // Dodanie nowego regału
      return await db.insert('shelf_unit', {
        'name': name.trim(),
        'shelf_count': shelfCount,
        'same_shelf': sameShelf,
        'is_horizontal': isHorizontal, // Dodanie nowej kolumny
      });
    } catch (e) {
      _logger.e('Error inserting shelf unit: $e');
      return -1;
    }
  }

  Future<int> updateExhibit(int id, Map<String, dynamic> exhibit) async {
    final db = await database;
    return await db.update(
      'exhibits',
      exhibit,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateShelfUnit(int id, String name, int shelfCount,
      int sameShelf, int isHorizontal) async {
    final db = await database;

    try {
      // Aktualizuj regał w bazie danych
      return await db.update(
        'shelf_unit',
        {
          'name': name.trim(),
          'shelf_count': shelfCount,
          'same_shelf': sameShelf,
          'is_horizontal': isHorizontal,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.e('Error updating shelf unit: $e');
      return -1; // Zwraca -1 w przypadku błędu
    }
  }

  Future<int> insertExhibit(Map<String, dynamic> exhibit) async {
    final db = await database;

    try {
      // Sprawdzenie, czy wystawa już istnieje
      final existingExhibit = await db.query(
        'exhibits',
        where: 'LOWER(TRIM(name)) = ? AND LOWER(TRIM(location)) = ?',
        whereArgs: [
          exhibit['name'].toString().trim().toLowerCase(),
          exhibit['location'].toString().trim().toLowerCase(),
        ],
        limit: 1,
      );

      if (existingExhibit.isNotEmpty) {
        _logger.d(
            'Exhibit already exists: ${exhibit['name']} at ${exhibit['location']}');
        return -1; // Kod błędu dla duplikatu
      }

      // Wstawienie nowej wystawy
      return await db.insert('exhibits', exhibit);
    } catch (e) {
      _logger.e('Error inserting exhibit: $e');
      return -1;
    }
  }

  Future<int> insertBox(Map<String, dynamic> box) async {
    final db = await database;

    // Sprawdzenie, czy istnieje już wpis o tej samej nazwie i wymiarach
    final existing = await db.query(
      'boxes',
      where: 'name = ? AND width = ? AND height = ? AND depth = ?',
      whereArgs: [box['name'], box['width'], box['height'], box['depth']],
    );

    if (existing.isNotEmpty) {
      // Zwróć -1, jeśli wpis już istnieje
      return -1;
    }

    // Wstaw nowy rekord
    return await db.insert('boxes', box);
  }

  Future<int> updateBox(int id, Map<String, dynamic> box) async {
    final db = await database;
    return await db.update(
      'boxes',
      box,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBox(int id) async {
    final db = await database;
    return await db.delete('boxes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getExhibits() async {
    final db = await database;
    return await db.query('exhibits'); // Pobranie wszystkich danych z tabeli
  }

  Future<List<Map<String, dynamic>>> getBoxes() async {
    final db = await database;
    return await db.query('boxes');
  }

  Future<List<Map<String, dynamic>>> getShelfUnits() async {
    final db = await database;
    return await db.query(
        'shelf_unit'); // Pobieranie wszystkich regałów z tabeli `shelf_unit`
  }

  Future<List<Map<String, dynamic>>> getShelvesByShelfUnitId(
      int shelfUnitId) async {
    final db = await database;
    return await db.query(
      'shelves',
      where: 'shelf_unit_id = ?',
      whereArgs: [shelfUnitId],
    );
  }

  Future<int> deleteExhibit(int id) async {
    final db = await database;
    return await db.delete(
      'exhibits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
