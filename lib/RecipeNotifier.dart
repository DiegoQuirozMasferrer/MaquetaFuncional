import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'DatabaseHelper.dart';

class RecipeNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> recipes = [];

  Future<void> loadRecipes() async {
    final dbRecipes = await DatabaseHelper().getRecipes();
    recipes = dbRecipes.map((recipe) {
      return {
        ...recipe,
        'ingredients': recipe['ingredients'] is String
            ? jsonDecode(recipe['ingredients']) // Decodificar si es JSON
            : recipe['ingredients'],
        'preparationSteps': recipe['preparationSteps'] is String
            ? jsonDecode(recipe['preparationSteps']) // Decodificar si es JSON
            : recipe['preparationSteps'],
      };
    }).toList();
    notifyListeners();
  }

  Future<void> loadPredefinedRecipes() async {
    try {
      // Verificar si ya existen recetas predefinidas en la base de datos
      final existingRecipes = await DatabaseHelper().getPredefinedRecipes();
      if (existingRecipes.isNotEmpty) {
        print('Las recetas predefinidas ya están cargadas.');
        return; // No cargar de nuevo si ya existen
      }

      // Cargar recetas predefinidas desde JSON
      final String jsonString = await rootBundle.loadString('assets/predefined_recipes.json');
      List<dynamic> predefinedRecipes = jsonDecode(jsonString);

      for (var recipe in predefinedRecipes) {
        recipe['isPredefined'] = 1; // Marcar como predefinidas
        await DatabaseHelper().insertRecipe(recipe);
        recipes.add(recipe);
      }

      notifyListeners();
    } catch (e) {
      print('Error al cargar recetas predefinidas: $e');
    }
  }

  void addRecipe(Map<String, dynamic> newRecipe) async {
    final db = await DatabaseHelper().database;
    try {
      newRecipe['ingredients'] = jsonEncode(newRecipe['ingredients']);
      newRecipe['preparationSteps'] = jsonEncode(newRecipe['preparationSteps']);
      int id = await db.insert('recipes', newRecipe);
      newRecipe['id'] = id;
      recipes.add(newRecipe);
      notifyListeners();
    } catch (e) {
      print('Error al agregar receta: $e');
    }
  }

  Future<void> deleteRecipe(int id) async {
    await DatabaseHelper().deleteRecipe(id);
    recipes.removeWhere((recipe) => recipe['id'] == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(int index) async {
    Map<String, dynamic> recipe = Map<String, dynamic>.from(recipes[index]);
    recipe['isFavorite'] = recipe['isFavorite'] == 1 ? 0 : 1;

    await DatabaseHelper().updateFavoriteStatus(recipe['id'], recipe['isFavorite']);
    recipes[index] = recipe;
    notifyListeners();
  }

  void updateRecipe(Map<String, dynamic> updatedRecipe) async {
    // Convertir listas a JSON solo si no están codificadas
    if (updatedRecipe['ingredients'] is List) {
      updatedRecipe['ingredients'] = jsonEncode(updatedRecipe['ingredients']);
    }
    if (updatedRecipe['preparationSteps'] is List) {
      updatedRecipe['preparationSteps'] = jsonEncode(updatedRecipe['preparationSteps']);
    }

    await DatabaseHelper().updateRecipe(updatedRecipe);

    int index = recipes.indexWhere((recipe) => recipe['id'] == updatedRecipe['id']);
    if (index != -1) {
      recipes[index] = {
        ...recipes[index],
        ...updatedRecipe,
        'lastModified': DateTime.now().toIso8601String(),
      };

      print('Receta actualizada: ${recipes[index]['name']}');
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get favoriteRecipes {
    return recipes.where((recipe) => recipe['isFavorite'] == 1).toList();
  }

  Future<int> getRecipeCount() async {
    final allRecipes = await DatabaseHelper().getRecipes();
    return allRecipes.length;
  }
}
