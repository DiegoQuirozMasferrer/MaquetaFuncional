import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
// Inicializar la base de datos
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    return await openDatabase(
      path,
      version: 2, // Incrementa la versión de la base de datos
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          ingredients TEXT,
          preparationMethod TEXT,
          extractionMethod TEXT,
          isFavorite INTEGER,
          imagePath TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migración para añadir la columna 'imagePath'
          await db.execute('''
          ALTER TABLE recipes ADD COLUMN imagePath TEXT
        ''');
        }
      },
    );
  }

  // Método para insertar una receta
  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    return await db.insert('recipes', recipe, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Método para obtener todas las recetas
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    return await db.query('recipes');
  }

  // Método para actualizar el estado de favorito
  Future<void> updateFavoriteStatus(int id, int isFavorite) async {
    final db = await database;
    await db.update(
      'recipes',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    await db.update(
      'recipes',
      recipe,
      where: 'id = ?',
      whereArgs: [recipe['id']],
    );
  }
  Future<List<Map<String, dynamic>>> getPredefinedRecipes() async {
    final db = await database;
    return await db.query('recipes', where: 'isPredefined = ?', whereArgs: [1]);
  }
}
