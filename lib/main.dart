import 'dart:io';

import 'package:flutter/material.dart';
import 'FeedbackScreen.dart';
import 'RecipeDetailsScreen.dart';
import 'RecipeNotifier.dart';
import 'package:provider/provider.dart';

import 'RecipeListScreen.dart';
import 'SettingsScreen.dart';
import 'ThemeNotifier.dart';
import 'UploadRecipeScreen.dart';
import 'SplashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'BaristaRecipesScreen.dart';
import 'package:maquetafuncional_cafe/RecipeDetailsScreen.dart' as details;

class CafeRecipeApp extends StatefulWidget {
  @override
  _CafeRecipeAppState createState() => _CafeRecipeAppState();
}

class _CafeRecipeAppState extends State<CafeRecipeApp> {


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Café Recipes',
          theme: themeNotifier.currentTheme,  // Tema actual manejado por ThemeNotifier
          home: SplashScreen(),  // Pantalla de presentación inicial
        );
      },
    );
  }
}
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => RecipeNotifier()),
      ],
      child: CafeRecipeApp(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  HomeScreen({Key? key, required this.recipes}) : super(key: key);


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
    recipeNotifier.loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context);

    // Filtrar las recetas favoritas
    List<Map<String, dynamic>> favoriteRecipes = recipeNotifier.recipes
        .where((recipe) => recipe['isFavorite'] == 1)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Tus Favoritos'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // Fondo de la pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          favoriteRecipes.isEmpty
              ? Center(
            child: Text(
              'No tienes recetas favoritas',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
              : ListView.builder(
            itemCount: favoriteRecipes.length,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                margin: EdgeInsets.only(bottom: 15),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(recipe: recipe),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty
                          ? (recipe['imagePath'].startsWith('assets/')
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          recipe['imagePath'],
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(recipe['imagePath']),
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ))
                          : Icon(
                        Icons.coffee,
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ),
                    ),
                    title: Text(
                      recipe['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                      ),
                    ),
                    subtitle: Text(
                      'Método: ${recipe['extractionMethod']}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        recipe['isFavorite'] == 1 ? Icons.favorite : Icons.favorite_border,
                        color: recipe['isFavorite'] == 1 ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        recipeNotifier.toggleFavorite(index);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );


  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            child: const Text(
              'Maestro Café',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.coffee),
            title: Text('Mi Barista'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BaristaRecipesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Ver Recetas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeListScreen(),
                ),
              ).then((_) {
                _scaffoldKey.currentState?.openEndDrawer();
                setState(() {});
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Subir Receta'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadRecipeScreen(),
                ),
              ).then((_) {
                _scaffoldKey.currentState?.openEndDrawer();
                setState(() {});
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuraciones'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ).then((_) {
                _scaffoldKey.currentState?.openEndDrawer();
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Enviar Feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              ).then((_) {
                _scaffoldKey.currentState?.openEndDrawer();
              });
            },
          ),
        ],
      ),
    );
  }

}