import 'package:flutter/material.dart';



class RecipeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailsScreen({required this.recipe}); // Constructor que acepta un Map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']), // Título de la receta en el AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de Extracción: ${recipe['extractionMethod']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Ingredientes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(recipe['ingredients']),
            SizedBox(height: 20),
            Text(
              'Método de Preparación:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(recipe['preparationMethod']),
          ],
        ),
      ),
    );
  }
}