import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  String? _extractionMethod;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Si estamos en modo edición, carga los datos existentes
    if (widget.isEditing && widget.recipeToEdit != null) {
      _nameController.text = widget.recipeToEdit!['name'];
      _ingredientsController.text = widget.recipeToEdit!['ingredients'];
      _methodController.text = widget.recipeToEdit!['preparationMethod'];
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
  void _submitRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

      Map<String, dynamic> newRecipe = {
        'id': widget.isEditing ? widget.recipeToEdit!['id'] : null,
        'name': _nameController.text,
        'ingredients': _ingredientsController.text,
        'preparationMethod': _methodController.text,
        'extractionMethod': _extractionMethod,
        'isFavorite': widget.isEditing ? widget.recipeToEdit!['isFavorite'] : 0,
        'imagePath': _imagePath ?? '',
      };

      if (widget.isEditing) {
        recipeNotifier.updateRecipe(newRecipe);
      } else {
        recipeNotifier.addRecipe(newRecipe);
      }

      Navigator.pop(context);
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
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: 'Ingredientes'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _methodController,
                decoration: InputDecoration(labelText: 'Método de preparación'),
                maxLines: 5,
              ),
              SizedBox(height: 10),
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
