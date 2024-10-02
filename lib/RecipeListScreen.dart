import 'package:flutter/material.dart';
import 'package:maquetafuncional_cafe/UploadRecipeScreen.dart';

import 'RecipeDetailsScreen.dart';

class RecipeListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  RecipeListScreen({required this.recipes});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  bool showFavoritesOnly = false;


  void _toggleFavoriteFilter() {
    setState(() {
      showFavoritesOnly = !showFavoritesOnly;
    });
  }


  void _toggleFavorite(int index) {
    setState(() {
      widget.recipes[index]['isFavorite'] = !widget.recipes[index]['isFavorite'];
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> displayedRecipes = showFavoritesOnly
        ? widget.recipes.where((recipe) => recipe['isFavorite']).toList()
        : widget.recipes;

    return Scaffold(
      appBar: AppBar(
        title: Text(showFavoritesOnly ? 'Favoritos' : 'Lista de Recetas'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [

          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: showFavoritesOnly ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavoriteFilter,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          displayedRecipes.isEmpty
              ? Center(
            child: Text(
              showFavoritesOnly
                  ? 'No tienes recetas favoritas'
                  : 'No hay recetas guardadas',
              style: TextStyle(fontSize: 18,  color : Colors.white ) ,


            ),
          )
              : ListView.builder(
            itemCount: displayedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = displayedRecipes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: Icon(
                      Icons.coffee,
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      size: 40,
                    ),
                    title: Text(
                      recipe['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .appBarTheme
                            .backgroundColor,
                      ),
                    ),
                    subtitle: Text(
                      'Método de extracción: ${recipe['extractionMethod']}\nIngredientes: ${recipe['ingredients']}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        recipe['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: recipe['isFavorite']
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleFavorite(index); //  favorito
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailsScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadRecipeScreen(recipes: widget.recipes),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),



    );
  }
}
