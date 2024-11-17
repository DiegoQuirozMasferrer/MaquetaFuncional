import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'RecipeNotifier.dart';
import 'EditRecipeScreen.dart';

class BaristaRecipesScreen extends StatefulWidget {
  @override
  _BaristaRecipesScreenState createState() => _BaristaRecipesScreenState();
}

class _BaristaRecipesScreenState extends State<BaristaRecipesScreen> {
  List<Map<String, dynamic>> baristaRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadBaristaRecipes();
  }

  Future<void> _loadBaristaRecipes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/predefined_recipes.json');
      List<dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        baristaRecipes = List<Map<String, dynamic>>.from(jsonResponse);
      });
    } catch (e) {
      print('Error al cargar recetas predefinidas: $e');
    }
  }

  void _editRecipe(BuildContext context, Map<String, dynamic> recipe) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

    // Verificar si la receta tiene un ID; si no, asignar uno temporal
    if (!recipe.containsKey('id') || recipe['id'] == null) {
      recipe['id'] = DateTime.now().millisecondsSinceEpoch;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(recipe: recipe),
      ),
    ).then((_) {
      recipeNotifier.loadRecipes();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Barista'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              recipeNotifier.loadRecipes();
              setState(() {});
            },
          ),
        ],
      ),
      body: baristaRecipes.isEmpty
          ? Center(child: Text('No hay recetas disponibles'))
          : ListView.builder(
        itemCount: baristaRecipes.length,
        itemBuilder: (context, index) {
          final recipe = baristaRecipes[index];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: SizedBox(
                width: 50,
                height: 50,
                child: recipe['imagePath'] != null &&
                    recipe['imagePath'].isNotEmpty &&
                    recipe['imagePath'].startsWith('assets/')
                    ? Image.asset(
                  recipe['imagePath'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: Colors.red),
                )
                    : Icon(Icons.coffee, size: 40, color: Colors.brown),
              ),
              title: Text(recipe['name']),
              subtitle: Text('Método: ${recipe['extractionMethod']}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRecipeScreen(recipe: baristaRecipes[index]),
                ),
              ).then((_) {

                setState(() {});
              }),
            ),
          );
        },
      ),
    );
  }
}
