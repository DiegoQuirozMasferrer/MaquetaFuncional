import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'RecipeNotifier.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailsScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Convertir los ingredientes y pasos de preparación a listas
    List<String> ingredients = [];
    List<String> preparationSteps = [];

    try {
      ingredients = recipe['ingredients'] is String
          ? List<String>.from(jsonDecode(recipe['ingredients']))
          : List<String>.from(recipe['ingredients']);
    } catch (e) {
      print('Error al decodificar ingredientes: ${recipe['ingredients']}');
    }

    try {
      preparationSteps = recipe['preparationSteps'] is String
          ? List<String>.from(jsonDecode(recipe['preparationSteps']))
          : List<String>.from(recipe['preparationSteps']);
    } catch (e) {
      print('Error al decodificar pasos de preparación: ${recipe['preparationSteps']}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareRecipe(ingredients, preparationSteps),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteRecipe(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              recipe['type'] == 'Café' ? '☕ Receta de Café' : '🍰 Receta de Torta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty)
              (recipe['imagePath'].startsWith('assets/')
                  ? Image.asset(recipe['imagePath'], height: 200, fit: BoxFit.cover)
                  : Image.file(File(recipe['imagePath']), height: 200, fit: BoxFit.cover)),
            SizedBox(height: 20),
            Text(
              'Ingredientes:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (ingredients.isEmpty)
              Text('No se proporcionaron ingredientes.')
            else
              ...ingredients.map((ingredient) => Text('- $ingredient')).toList(),
            SizedBox(height: 20),
            Text(
              'Pasos de Preparación:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (preparationSteps.isEmpty)
              Text('No se proporcionaron pasos de preparación.')
            else
              ...preparationSteps
                  .asMap()
                  .entries
                  .map((entry) => Text('${entry.key + 1}. ${entry.value}'))
                  .toList(),
            SizedBox(height: 20),
            if (recipe['type'] == 'Café' && recipe['extractionMethod'] != null)
              Text(
                'Método de Extracción: ${recipe['extractionMethod']}',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }

  void _shareRecipe(List<String> ingredients, List<String> preparationSteps) async {
    String recipeText = '''
    📋 Receta: ${recipe['name']}
    ${recipe['type'] == 'Café' ? '☕ Tipo: Café' : '🍰 Tipo: Torta'}
    🌟 Ingredientes:
    ${ingredients.isNotEmpty ? ingredients.map((e) => '- $e').join('\n') : 'No especificados'}
    📝 Pasos de Preparación:
    ${preparationSteps.isNotEmpty ? preparationSteps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n') : 'No especificados'}
    ${recipe['type'] == 'Café' && recipe['extractionMethod'] != null ? '☕ Método de Extracción: ${recipe['extractionMethod']}' : ''}
    ''';

    if (recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty) {
      try {
        String path = recipe['imagePath'];

        // Comprueba si es una imagen de los assets
        if (path.startsWith('assets/')) {
          // Copia la imagen de los assets a un directorio temporal antes de compartir
          ByteData byteData = await rootBundle.load(path);
          Directory tempDir = await getTemporaryDirectory();
          File tempImage = File('${tempDir.path}/${path.split('/').last}');
          await tempImage.writeAsBytes(byteData.buffer.asUint8List());

          path = tempImage.path;
        }

        // Comprueba si el archivo existe en la ruta
        File imageFile = File(path);
        if (await imageFile.exists()) {
          print('Compartiendo imagen desde: $path');

          // Usa Share.shareXFiles para compartir la imagen
          await Share.shareXFiles(
            [XFile(path)],
            text: recipeText,
          );
          return; // Sal del método después de compartir
        } else {
          print('La imagen no existe en la ruta: $path');
        }
      } catch (e) {
        print('Error al compartir la imagen: $e');
      }
    }

    // Comparte solo el texto si no hay imagen disponible
    print('Compartiendo solo texto porque no hay imagen.');
    await Share.share(recipeText);
  }



  void _deleteRecipe(BuildContext context) async {
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

    bool confirmed = await showDialog<bool>(
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
    ) ??
        false;

    if (confirmed) {
      recipeNotifier.deleteRecipe(recipe['id']);
      Navigator.pop(context); // Cerrar la pantalla de detalles
    }
  }
}
