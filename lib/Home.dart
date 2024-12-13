import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DatabaseHelper.dart';
import 'MiOpinion.dart';
import 'RecipeDetails.dart';
import 'RecipeNotifier.dart';
import 'package:provider/provider.dart';

import 'SplashScreen.dart';
import 'MisRecetas.dart';
import 'ThemeNotifier.dart';
import 'MiBarista.dart';
import 'UploadRecipe.dart';

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
          theme: themeNotifier.currentTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}



class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  HomeScreen({Key? key, required this.recipes}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkIfTutorialSeen();
    final recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
    recipeNotifier.loadRecipes();
  }

  void _checkIfTutorialSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialSeen = prefs.getBool('tutorialSeen') ?? true;

    if (tutorialSeen!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
    }
  }

  void _showTutorial() {
    final steps = [
      {
        'title': 'Bienvenido a Maestro Café',
        'content': 'Explora el menú lateral para acceder a más opciones.',
        'icon': Icons.menu,
      },
      {
        'title': 'Última Receta',
        'content': 'Aquí puedes ver la receta más reciente creada o editada.',
        'icon': Icons.receipt_long,
      },
      {
        'title': 'Agregar Receta',
        'content': 'Utiliza el botón flotante para agregar una nueva receta.',
        'icon': Icons.add,
      },
      {
        'title': 'Ver Recetas',
        'content': 'Utiliza el botón flotante para agregar una nueva receta.',
        'icon': Icons.coffee,
      }
    ];

    int currentStep = 0;

    void showNextDialog() {
      if (currentStep < steps.length) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    steps[currentStep]['icon'] as IconData,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[currentStep]['title'] as String,
                      style: TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis, // Para evitar el desbordamiento
                    ),
                  ),
                ],
              ),
              content: Text(steps[currentStep]['content'] as String),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _skipTutorial();
                  },
                  child: Text('No mostrar de nuevo'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    currentStep++;
                    showNextDialog();
                  },
                  child: Text('Siguiente'),
                ),
              ],
            );
          },
        );
      }
    }

    showNextDialog();
  }




  void _skipTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialSeen', true);
  }

  void _resetTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialSeen', false);
    _showTutorial();
  }

  @override
  Widget build(BuildContext context) {
    final recipeNotifier = Provider.of<RecipeNotifier>(context);

    List<Map<String, dynamic>> sortedRecipes = List.from(recipeNotifier.recipes)
      ..sort((a, b) {
        DateTime dateA = a['lastModified'] != null
            ? DateTime.parse(a['lastModified'])
            : (a['created'] != null ? DateTime.parse(a['created']) : DateTime(0));
        DateTime dateB = b['lastModified'] != null
            ? DateTime.parse(b['lastModified'])
            : (b['created'] != null ? DateTime.parse(b['created']) : DateTime(0));

        return dateB.compareTo(dateA);
      });

    Map<String, dynamic>? latestRecipe =
    sortedRecipes.isNotEmpty ? sortedRecipes.first : null;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Última Receta'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/Inicio.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              latestRecipe == null
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No hay recetas disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
                  : _buildRecipeCard(latestRecipe),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadRecipeScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: _buildRecipeImage(recipe),
          title: Text(
            recipe['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Método: ${recipe['extractionMethod']}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsScreen(recipe: recipe),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Map<String, dynamic> recipe) {
    if (recipe['imagePath'] != null && recipe['imagePath'].isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: recipe['imagePath'].startsWith('assets/')
            ? Image.asset(
          recipe['imagePath'],
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        )
            : Image.file(
          File(recipe['imagePath']),
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        ),
      );
    }
    return Icon(Icons.coffee, size: 50, color: Colors.brown);
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
            leading: Icon(Icons.refresh),
            title: Text('Reactivar Tutorial'),
            onTap: () {
              Navigator.pop(context);
              _resetTutorial();
            },
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
              );
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
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Tu oponion'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
