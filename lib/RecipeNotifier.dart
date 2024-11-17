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
    recipes = List<Map<String, dynamic>>.from(dbRecipes);

    // Cargar recetas predefinidas si aún no se han cargado


    notifyListeners();
  }
  Future<void> loadPredefinedRecipes() async {
    try {

      final existingRecipes = await DatabaseHelper().getPredefinedRecipes();
      if (existingRecipes.isNotEmpty) {
        print('Las recetas predefinidas ya están cargadas.');
        return; // No cargar de nuevo si ya existen
      }


      final String jsonString = await rootBundle.loadString('assets/predefined_recipes.json');
      List<dynamic> predefinedRecipes = jsonDecode(jsonString);

      for (var recipe in predefinedRecipes) {

        recipe['isPredefined'] = 1;
        await DatabaseHelper().insertRecipe(recipe);
        recipes.add(recipe);
      }

      notifyListeners();
    } catch (e) {
      print('Error al cargar recetas bd: $e');
    }
  }

  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    await DatabaseHelper().insertRecipe(recipe);
    recipes.add(recipe);
    await loadRecipes();
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
  Future<void> updateRecipe(Map<String, dynamic> recipe) async {
    if (recipe['id'] != null) {
      await DatabaseHelper().updateRecipe(recipe);
    } else {
      await addRecipe(recipe);
    }
    await loadRecipes();
  }



  List<Map<String, dynamic>> get favoriteRecipes {
    return recipes.where((recipe) => recipe['isFavorite'] == 1).toList();
  }

  Future<int> getRecipeCount() async {
    final allRecipes = await DatabaseHelper().getRecipes();
    return allRecipes.length;
  }
}

