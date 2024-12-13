import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'RecipeDetails.dart';
import 'RecipeNotifier.dart';
import 'UploadRecipe.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String? _type; // Tipo de receta seleccionado
  String? _extractionMethod; // Tipo de receta seleccionado

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
    recipeNotifier.loadRecipes();
  }


  @override
  Widget build(BuildContext context) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context);

    // Filtrar recetas por tipo y método de extracción seleccionados
    List<Map<String, dynamic>> filteredRecipes = recipeNotifier.recipes.where((recipe) {
      // Excluir recetas predefinidas que no hayan sido modificadas
      if (recipe['isPredefined'] == 1 && recipe['lastModified'] == null) {
        return false;
      }
      // Filtrar por tipo si está seleccionado
      if (_type != null && recipe['type'] != _type) {
        return false;
      }
      // Filtrar por método de extracción si está seleccionado
      if (_extractionMethod != null && recipe['extractionMethod'] != _extractionMethod) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Recetas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRecipes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar el tipo de receta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Filtrar por tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                null, // Opción para mostrar todas las recetas
                'Café',
                'Pastel',
                'Té'

              ].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type ?? 'Todos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _type = value; // Actualizar tipo seleccionado
                });
              },
            ),
          ),
          // Dropdown para seleccionar el método de extracción
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _extractionMethod,
              decoration: InputDecoration(
                labelText: 'Filtrar por método de extracción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                null, // Opción para mostrar todos los métodos
                'Espresso',
                'Pour-over',
                'French Press',
                'Cold Brew'
              ].map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method ?? 'Todos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _extractionMethod = value; // Actualizar método de extracción seleccionado
                });
              },
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(child: Text('No hay recetas que coincidan con los filtros'))
                : ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: _buildFavoriteIcon(recipe, recipeNotifier, index),
                    title: Text(
                      recipe['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Tipo: ${recipe['type']}\nMétodo: ${recipe['extractionMethod']}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToEdit(context, recipe),
                        ),
                        _buildRecipeImage(recipe),
                      ],
                    ),
                    onTap: () => _navigateToDetails(context, recipe),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUpload(context),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }


  Widget _buildFavoriteIcon(
      Map<String, dynamic> recipe, RecipeNotifier recipeNotifier, int index) {
    return IconButton(
      icon: Icon(
        recipe['isFavorite'] == 1 ? Icons.favorite : Icons.favorite_border,
        color: recipe['isFavorite'] == 1 ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        recipeNotifier.toggleFavorite(index);
        setState(() {});
      },
    );
  }

  Widget _buildRecipeImage(Map<String, dynamic> recipe) {
    return SizedBox(
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
    );
  }

  void _navigateToDetails(BuildContext context, Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  void _navigateToUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadRecipeScreen(),
      ),
    ).then((_) => _loadRecipes());
  }

  void _navigateToEdit(BuildContext context, Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadRecipeScreen(
          recipeToEdit: recipe,
          isEditing: true,
        ),
      ),
    ).then((_) => _loadRecipes());
  }
}
