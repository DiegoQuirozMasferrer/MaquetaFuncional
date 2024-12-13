import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'EditRecipe.dart';
import 'RecipeDetails.dart';
import 'RecipeNotifier.dart';

class BaristaRecipesScreen extends StatefulWidget {
  @override
  _BaristaRecipesScreenState createState() => _BaristaRecipesScreenState();
}

class _BaristaRecipesScreenState extends State<BaristaRecipesScreen> {
  List<Map<String, dynamic>> baristaRecipes = [];
  String? _type; // Filtro de tipo
  String? _extractionMethod; // Filtro de método de extracción

  @override
  void initState() {
    super.initState();
    _loadBaristaRecipes();
  }

  Future<void> _loadBaristaRecipes() async {
    try {
      final String jsonString =
      await rootBundle.loadString('assets/predefined_recipes.json');
      List<dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        baristaRecipes = List<Map<String, dynamic>>.from(jsonResponse).map((recipe) {
          return {
            ...recipe,
            'ingredients': recipe['ingredients'] is String
                ? recipe['ingredients'].split(',').map((e) => e.trim()).toList()
                : List<String>.from(recipe['ingredients'] ?? []),
            'preparationSteps': recipe['preparationSteps'] is String
                ? recipe['preparationSteps'].split('.').map((e) => e.trim()).toList()
                : List<String>.from(recipe['preparationSteps'] ?? []),
          };
        }).toList();
      });
    } catch (e) {
      print('Error al cargar recetas predefinidas: $e');
    }
  }
  Future<void> _editRecipe(BuildContext context, Map<String, dynamic> recipe) async {
    // Copiar imagen desde assets si es necesario
    String? newImagePath;
    if (recipe['imagePath'] != null && recipe['imagePath'].startsWith('assets/')) {
      newImagePath = await _copyAssetImageToLocal(recipe['imagePath']);
    }

    // Crear una copia de la receta predefinida
    Map<String, dynamic> recipeCopy = {
      ...recipe,
      'id': null, // Generar nuevo id automáticamente
      'imagePath': newImagePath ?? recipe['imagePath'],
      'isFavorite': 0, // Valor predeterminado para "favorito"
      'created': DateTime.now().toIso8601String(),
      'lastModified': DateTime.now().toIso8601String(),
    };

    // Navegar a la pantalla de edición con la copia de la receta
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(recipe: recipeCopy, isFromBarista: true),
      ),
    ).then((updatedRecipe) {
      if (updatedRecipe != null) {
        // Guardar la receta editada en la base de datos
        final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
        recipeNotifier.addRecipe(updatedRecipe);
      }
      setState(() {});
    });
  }



  Future<String> _copyAssetImageToLocal(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${assetPath.split('/').last}';
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }


  @override
  Widget build(BuildContext context) {
    // Filtrar recetas según el tipo y método de extracción seleccionados
    List<Map<String, dynamic>> filteredRecipes = baristaRecipes.where((recipe) {
      if (_type != null && recipe['type'] != _type) {
        return false;
      }
      if (_extractionMethod != null && recipe['extractionMethod'] != _extractionMethod) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Barista'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBaristaRecipes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown para filtrar por tipo
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
                'Té',
              ].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type ?? 'Todos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _type = value;
                });
              },
            ),
          ),
          // Dropdown para filtrar por método de extracción
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
                'Cold Brew',
              ].map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method ?? 'Todos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _extractionMethod = value;
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
                    contentPadding: EdgeInsets.all(16),
                    leading: _buildRecipeImage(recipe),
                    title: Text(recipe['name']),
                    subtitle: Text('Tipo: ${recipe['type'] ?? 'Desconocido'}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(recipe: recipe),
                      ),
                    ).then((_) {
                      setState(() {});
                    }),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editRecipe(context, recipe),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(Map<String, dynamic> recipe) {
    if (recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty) {
      if (recipe['imagePath'].startsWith('assets/')) {
        return Image.asset(
          recipe['imagePath'],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, size: 40, color: Colors.red);
          },
        );
      } else if (File(recipe['imagePath']).existsSync()) {
        return Image.file(
          File(recipe['imagePath']),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      }
    }
    return Icon(Icons.coffee, size: 40, color: Colors.brown);
  }
}
