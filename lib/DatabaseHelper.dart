import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    return await openDatabase(
      path,
      version: 2, // Incrementar la versión para aplicar migraciones
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          ingredients TEXT NOT NULL,
          preparationSteps TEXT NOT NULL,
          type TEXT,
          extractionMethod TEXT,
          isFavorite INTEGER DEFAULT 0,
          imagePath TEXT,
          created TEXT,
          lastModified TEXT
        )
        ''');
        print("Tabla 'recipes' creada exitosamente.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE recipes ADD COLUMN created TEXT');
          await db.execute('ALTER TABLE recipes ADD COLUMN lastModified TEXT');
          print("Migración completada: columnas 'created' y 'lastModified' añadidas.");
        }
      },
    );
  }

  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;

    // Convertir listas a JSON antes de insertarlas solo si no están codificadas
    if (recipe['ingredients'] is List) {
      recipe['ingredients'] = jsonEncode(recipe['ingredients']);
    }
    if (recipe['preparationSteps'] is List) {
      recipe['preparationSteps'] = jsonEncode(recipe['preparationSteps']);
    }

    return await db.insert(
      'recipes',
      recipe,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    return await db.query('recipes');
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    await db.update('recipes', recipe, where: 'id = ?', whereArgs: [recipe['id']]);
  }

  Future<void> updateFavoriteStatus(int id, int isFavorite) async {
    final db = await database;
    await db.update('recipes', {'isFavorite': isFavorite}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPredefinedRecipes() async {
    final db = await database;
    return await db.query('recipes', where: 'isPredefined = ?', whereArgs: [1]);
  }
  Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'recipes.db');

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print('Base de datos eliminada.');
    } else {
      print('No se encontró la base de datos.');
    }
  }
}
