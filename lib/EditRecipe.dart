import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'RecipeNotifier.dart';

class EditRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool isFromBarista; // Indica si la receta proviene de "MiBarista"

  EditRecipeScreen({required this.recipe, this.isFromBarista = false});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<String> _ingredients;
  late List<String> _preparationSteps;
  String? _imagePath;
  String? _extractionMethod;
  String? _recipeType;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe['name']);

    _ingredients = widget.recipe['ingredients'] is List
        ? List<String>.from(widget.recipe['ingredients'])
        : widget.recipe['ingredients'] is String
        ? List<String>.from(jsonDecode(widget.recipe['ingredients']))
        : [];

    _preparationSteps = widget.recipe['preparationMethod'] is List
        ? List<String>.from(widget.recipe['preparationMethod'])
        : widget.recipe['preparationMethod'] is String
        ? List<String>.from(jsonDecode(widget.recipe['preparationMethod']))
        : [];

    _imagePath = widget.recipe['imagePath'];
    _extractionMethod = widget.recipe['extractionMethod'];
    _recipeType = widget.recipe['type'];


    if (widget.isFromBarista && _imagePath != null && _imagePath!.startsWith('assets/')) {
      _copyAssetImageToLocal(_imagePath!).then((localPath) {
        setState(() {
          _imagePath = localPath;
        });
      });
    }
  }

  Future<String> _copyAssetImageToLocal(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${assetPath.split('/').last}';
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

      final updatedRecipe = {
        'id': widget.isFromBarista ? null : widget.recipe['id'],
        'name': _nameController.text,
        'ingredients': _ingredients is List
            ? jsonEncode(_ingredients) // Codifica solo si es una lista
            : _ingredients, // Deja el valor como está si ya está codificado
        'preparationSteps': _preparationSteps is List
            ? jsonEncode(_preparationSteps) // Codifica solo si es una lista
            : _preparationSteps, // Deja el valor como está si ya está codificado
        'imagePath': _imagePath ?? '',
        'created': widget.recipe['created'] ?? DateTime.now().toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
        'type': _recipeType,
        if (_recipeType == 'Café') 'extractionMethod': _extractionMethod,
      };

      try {
        if (widget.isFromBarista) {
          // Si la receta proviene de MiBarista, crear una copia en la base de datos
          recipeNotifier.addRecipe(updatedRecipe);
        } else {
          // Si es una receta existente, simplemente actualizar
          recipeNotifier.updateRecipe(updatedRecipe);
        }
        Navigator.pop(context);
      } catch (e) {
        print('Error al guardar la receta: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFromBarista ? 'Añadir Receta' : 'Editar Receta'),
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
              SizedBox(height: 20),
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
              _buildIngredientSection(),
              SizedBox(height: 20),
              _buildPreparationStepsSection(),
              SizedBox(height: 20),
              if (_imagePath != null && _imagePath!.isNotEmpty)
                Image.file(
                  File(_imagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 10),
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
              ElevatedButton(
                onPressed: _saveRecipe,
                child: Text(widget.isFromBarista ? 'Añadir Receta' : 'Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredientes:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._ingredients.map((ingredient) {
          return ListTile(
            title: Text(ingredient),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _ingredients.remove(ingredient);
                });
              },
            ),
          );
        }).toList(),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _addItemToList('ingrediente'),
          child: Text('Añadir Ingrediente'),
        ),
      ],
    );
  }

  Widget _buildPreparationStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasos de Preparación:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._preparationSteps.map((step) {
          return ListTile(
            title: Text(step),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _preparationSteps.remove(step);
                });
              },
            ),
          );
        }).toList(),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _addItemToList('paso de preparación'),
          child: Text('Añadir Paso'),
        ),
      ],
    );
  }

  void _addItemToList(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir $type'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Escribe aquí el $type'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (type == 'ingrediente') {
                    _ingredients.add(controller.text);
                  } else if (type == 'paso de preparación') {
                    _preparationSteps.add(controller.text);
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Añadir'),
            ),
          ],
        );
      },
    );
  }
}
