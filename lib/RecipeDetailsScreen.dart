import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'RecipeNotifier.dart';
import 'EditRecipeScreen.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailsScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareRecipe(recipe),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [

            recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty
                ? (recipe['imagePath'].startsWith('assets/')
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                recipe['imagePath'],
                height: 200,
                fit: BoxFit.cover,
              ),
            )
                : (File(recipe['imagePath']).existsSync()
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(recipe['imagePath']),
                height: 200,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.coffee, size: 100, color: Colors.brown)))
                : Icon(Icons.coffee, size: 100, color: Colors.brown),
            SizedBox(height: 20),

            // Información de la receta
            Text(
              'Método de Extracción: ${recipe['extractionMethod']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Ingredientes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(recipe['ingredients']),
            SizedBox(height: 20),
            Text('Método de Preparación:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(recipe['preparationMethod']),
            SizedBox(height: 30),

            // Botón para Editar Receta
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRecipeScreen(recipe: recipe),
                  ),
                ).then((_) {
                  recipeNotifier.loadRecipes(); // Recargar recetas después de la edición
                });
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text('Editar Receta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Botón para Eliminar Receta
            ElevatedButton.icon(
              onPressed: () async {
                bool confirmed = await _showDeleteConfirmationDialog(context);
                if (confirmed) {
                  recipeNotifier.deleteRecipe(recipe['id']);
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text('Eliminar Receta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  // Función para compartir la receta
  Future<void> _shareRecipe(Map<String, dynamic> recipe) async {
    String recipeText = '''
🍰 Receta: ${recipe['name']}
📝 Ingredientes: ${recipe['ingredients']}
🍳 Método de Preparación: ${recipe['preparationMethod']}
☕ Método de Extracción: ${recipe['extractionMethod']}
''';

    // Verificar si hay una imagen asociada
    if (recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty) {
      final imageFile = File(recipe['imagePath']);
      if (await imageFile.exists()) {
        // Usar shareXFiles para compartir la imagen y el texto
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: recipeText,
        );
      } else {
        // Compartir solo el texto si la imagen no existe
        await Share.share(recipeText);
      }
    } else {
      // Compartir solo el texto si no hay imagen
      await Share.share(recipeText);
    }
  }


  // Diálogo de confirmación para eliminar
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Receta'),
        content: Text('¿Estás seguro de que deseas eliminar esta receta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }
}
