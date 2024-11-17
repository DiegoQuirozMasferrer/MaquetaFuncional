import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'RecipeNotifier.dart';
import 'RecipeDetailsScreen.dart';
import 'UploadRecipeScreen.dart';
import 'dart:io';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
    recipeNotifier.loadRecipes();
  }

  void _refreshRecipes() {
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
    recipeNotifier.loadRecipes();
    setState(() {}); // Forzar la actualización de la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Recetas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshRecipes,
          ),
        ],
      ),
      body: recipeNotifier.recipes.isEmpty
          ? Center(child: Text('No hay recetas guardadas'))
          : ListView.builder(
        itemCount: recipeNotifier.recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipeNotifier.recipes[index];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              leading: SizedBox(
                width: 50,
                height: 50,
                child: IconButton(
                  icon: Icon(
                    recipe['isFavorite'] == 1 ? Icons.favorite : Icons.favorite_border,
                    color: recipe['isFavorite'] == 1 ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    recipeNotifier.toggleFavorite(index);
                    setState(() {});
                  },
                ),
              ),
              title: Text(
                recipe['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Método: ${recipe['extractionMethod']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              trailing: SizedBox(
                width: 60,
                height: 60,
                child: recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty
                    ? (recipe['imagePath'].startsWith('assets/')
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    recipe['imagePath'],
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(recipe['imagePath']),
                    fit: BoxFit.cover,
                  ),
                ))
                    : Icon(Icons.coffee, size: 40, color: Colors.brown),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsScreen(recipe: recipe),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadRecipeScreen()),
          ).then((_) => _refreshRecipes()); // Refrescar al volver
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
