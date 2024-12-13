
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'DatabaseHelper.dart';
import 'RecipeNotifier.dart';

class UploadRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? recipeToEdit;
  final bool isEditing;

  UploadRecipeScreen({this.recipeToEdit, this.isEditing = false});

  @override
  _UploadRecipeScreenState createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  String? _recipeType;
  String? _extractionMethod;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();
  List<String> _ingredients = [];
  List<String> _preparationMethod = [];

  @override
  void initState() {
    super.initState();
    // Si estamos en modo edición, carga los datos existentes
    if (widget.isEditing && widget.recipeToEdit != null) {
      _nameController.text = widget.recipeToEdit!['name'];
      _ingredients = widget.recipeToEdit!['ingredients'] is String
          ? List<String>.from(jsonDecode(widget.recipeToEdit!['ingredients']))
          : List<String>.from(widget.recipeToEdit!['ingredients'] ?? []);
      _preparationMethod = widget.recipeToEdit!['preparationSteps'] is String
          ? List<String>.from(jsonDecode(widget.recipeToEdit!['preparationSteps']))
          : List<String>.from(widget.recipeToEdit!['preparationSteps'] ?? []);
      _recipeType = widget.recipeToEdit!['type'] ?? 'Café';
      _extractionMethod = widget.recipeToEdit!['extractionMethod'];
      _imagePath = widget.recipeToEdit!['imagePath'] ?? '';
    }
  }

  // Función para seleccionar imagen desde la galería
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // Función para seleccionar imagen desde la cámara
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // Guardar la receta
  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

      Map<String, dynamic> newRecipe = {
        'name': _nameController.text, // Usar el texto ingresado en el nombre
        'ingredients': _ingredients, // Guardar directamente la lista
        'preparationSteps': _preparationMethod, // Guardar directamente la lista
        'type': _recipeType, // Tipo seleccionado por el usuario
        'extractionMethod': _recipeType == 'Café' ? _extractionMethod : null, // Método de extracción solo para recetas de café
        'isFavorite': 0, // Valor predeterminado para "favorito"
        'imagePath': _imagePath ?? '', // Ruta de la imagen seleccionada
        'created': DateTime.now().toIso8601String(), // Fecha actual
        'lastModified': DateTime.now().toIso8601String(), // Fecha actual
      };

      try {
        if (widget.isEditing) {
          // Actualizar receta existente
          newRecipe['id'] = widget.recipeToEdit!['id'];
          recipeNotifier.updateRecipe(newRecipe);
        } else {
          // Agregar nueva receta
          recipeNotifier.addRecipe(newRecipe);
        }

        Navigator.pop(context); // Cerrar la pantalla después de guardar
      } catch (e) {
        print('Error al agregar receta: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la receta.')),
        );
      }
    }
  }




  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _preparationMethod.add(_stepController.text);
        _stepController.clear();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Receta' : 'Subir Receta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre de la receta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _recipeType,
                items: ['Café', 'Pastel'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _recipeType = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Tipo de receta'),
              ),
              if (_recipeType == 'Café')
                DropdownButtonFormField<String>(
                  value: _extractionMethod,
                  items: ['Espresso', 'Pour-over', 'Cold Brew', 'French Press']
                      .map((method) => DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _extractionMethod = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Método de Extracción'),
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ingredientController,
                decoration: InputDecoration(
                  labelText: 'Agregar Ingrediente',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addIngredient,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Ingredientes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._ingredients.map((ingredient) => ListTile(
                title: Text(ingredient),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _ingredients.remove(ingredient);
                    });
                  },
                ),
              )),
              SizedBox(height: 20),
              TextFormField(
                controller: _stepController,
                decoration: InputDecoration(
                  labelText: 'Agregar Paso de Preparación',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addStep,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Pasos de Preparación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._preparationMethod.map((step) => ListTile(
                title: Text(step),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _preparationMethod.remove(step);
                    });
                  },
                ),
              )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: Icon(Icons.photo_library),
                    label: Text('Galería'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Cámara'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_imagePath != null && _imagePath!.isNotEmpty)
                Image.file(
                  File(_imagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRecipe,
                child: Text(widget.isEditing ? 'Guardar Cambios' : 'Subir Receta'),

              ),
            ],
          ),
        ),
      ),
    );
  }
}