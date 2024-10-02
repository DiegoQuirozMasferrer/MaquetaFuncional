import 'package:flutter/material.dart';
import 'package:maquetafuncional_cafe/RecipeListScreen.dart';

import 'main.dart';



class UploadRecipeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  UploadRecipeScreen({required this.recipes});

  @override
  _UploadRecipeScreenState createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  String? _extractionMethod = 'Espresso';


  void _submitRecipe() {
    if (_formKey.currentState!.validate()) {
      setState(() {

        widget.recipes.add({
          'name': _nameController.text,
          'ingredients': _ingredientsController.text,
          'preparationMethod': _methodController.text,
          'extractionMethod': _extractionMethod,
          'isFavorite': false,
        });
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RecipeListScreen(recipes: widget.recipes,)),

          result: ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Receta creada')),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;


    final borderColor = isDarkMode ? Colors.brown : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Receta'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Stack(
        children: [

          Positioned.fill(
            child: ColorFiltered(
              colorFilter: isDarkMode
                  ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken) // Oscurece el fondo
                  : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // El contenido del formulario
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Receta',
                      labelStyle: TextStyle(color: borderColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                    ),
                    style: TextStyle(color:borderColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el nombre de la receta';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: InputDecoration(
                      labelText: 'Ingredientes',
                      hintText: 'Separar los ingredientes por comas',
                      labelStyle: TextStyle(color: borderColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                    ),
                    style: TextStyle(color: borderColor),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa los ingredientes';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _methodController,
                    decoration: InputDecoration(

                      labelText: 'Método de Preparación',
                      hintText: 'Describe cómo preparar la receta',
                      labelStyle: TextStyle(color: borderColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                    ),
                    style: TextStyle(color: borderColor),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, describe el método de preparación';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _extractionMethod,
                    decoration: InputDecoration(
                      labelText: 'Método de Extracción',
                      labelStyle: TextStyle(color: borderColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                    ),
                    items: <String>['Espresso', 'Pour-over', 'Cold Brew', 'French Press']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _extractionMethod = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecciona un método de extracción';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitRecipe,
                    child: Text('Subir Receta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: borderColor),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(12), // Bordes redondeados del botón
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// Pantalla de detalles de la receta
