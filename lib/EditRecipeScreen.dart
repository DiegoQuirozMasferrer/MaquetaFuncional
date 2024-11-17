import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'RecipeNotifier.dart';
import 'package:path_provider/path_provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  EditRecipeScreen({required this.recipe});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ingredientsController;
  late TextEditingController _methodController;
  late String _extractionMethod;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe['name']);
    _ingredientsController = TextEditingController(text: widget.recipe['ingredients']);
    _methodController = TextEditingController(text: widget.recipe['preparationMethod']);
    _extractionMethod = widget.recipe['extractionMethod'];
    _imagePath = widget.recipe['imagePath'];

    // Si la imagen es de assets, copia al almacenamiento local
    if (_imagePath != null && _imagePath!.startsWith('assets/')) {
      _copyAssetImageToLocal(_imagePath!).then((localPath) {
        setState(() {
          _imagePath = localPath;
        });
      });
    }
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

  /// Copia la imagen desde los assets a una ruta accesible en el dispositivo
  Future<String> _copyAssetImageToLocal(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/${assetPath.split('/').last}';
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);

      final updatedRecipe = {
        'id': widget.recipe.containsKey('id') && widget.recipe['id'] != null ? widget.recipe['id'] : null,
        'name': _nameController.text,
        'ingredients': _ingredientsController.text,
        'preparationMethod': _methodController.text,
        'extractionMethod': _extractionMethod,
        'isFavorite': widget.recipe['isFavorite'] ?? 0,
        'imagePath': _imagePath ?? ''
      };

      // Si la receta no tiene un ID (es una receta de Barista o una nueva), se guarda como nueva
      if (updatedRecipe['id'] != null) {
        await recipeNotifier.addRecipe(updatedRecipe);
        print('Nueva receta creada.');
      } else {
        // Si tiene un ID, se actualiza
        await recipeNotifier.updateRecipe(updatedRecipe);
        print('Receta actualizada.');
      }

      // Mostrar en la consola el total de recetas
      int totalRecipes = await recipeNotifier.getRecipeCount();
      print('Total de recetas almacenadas: $totalRecipes');

      Navigator.pop(context);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Receta'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la receta',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, ingresa el nombre' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ingredientsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ingredientes',
                  hintText: 'Separar los ingredientes por comas',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, ingresa los ingredientes' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _methodController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Método de Preparación',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, describe el método' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _extractionMethod,
                decoration: InputDecoration(
                  labelText: 'Método de Extracción',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Espresso', 'Pour-over', 'Cold Brew', 'French Press'].map((method) {
                  return DropdownMenuItem<String>(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) => setState(() => _extractionMethod = value!),
              ),
              SizedBox(height: 20),
              _imagePath != null && _imagePath!.isNotEmpty
                  ? Image.file(File(_imagePath!), height: 200, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100),
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
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
