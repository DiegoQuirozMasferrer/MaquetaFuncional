import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'RecipeDetailsScreen.dart';
import 'RecipeListScreen.dart';
import 'SettingsScreen.dart';
import 'ThemeNotifier.dart';
import 'UploadRecipeScreen.dart';
import 'SplashScreen.dart';

class CafeRecipeApp extends StatefulWidget {
  @override
  _CafeRecipeAppState createState() => _CafeRecipeAppState();
}

class _CafeRecipeAppState extends State<CafeRecipeApp> {
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Café Espresso',
      'extractionMethod': 'Espresso',
      'ingredients': 'Café molido, Agua',
      'preparationMethod': 'Preparar el café con una máquina de espresso...',
      'isFavorite': false,
    },
    {
      'name': 'Cold Brew',
      'extractionMethod': 'Cold Brew',
      'ingredients': 'Café molido grueso, Agua fría',
      'preparationMethod': 'Preparar el café en frío por inmersión...',
      'isFavorite': true,
    },
  ];

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
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: CafeRecipeApp(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  HomeScreen({required this.recipes});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Filtrar las favoritas
    List<Map<String, dynamic>> favoriteRecipes = widget.recipes
        .where((recipe) => recipe['isFavorite'] == true)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // fondo
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          favoriteRecipes.isEmpty
              ? const Center(
            child: Text(
              'No tienes recetas favoritas',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailsScreen(recipe: recipe),
                        ),
                      ).then((_) {
                        setState(() {

                        });
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              color: Theme.of(context).primaryColorLight,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.coffee,
                                color: Colors.brown,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            recipe['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Método: ${recipe['extractionMethod']}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
              'Maestro Café ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Ver Recetas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecipeListScreen(recipes: widget.recipes),
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
                  builder: (context) =>
                      UploadRecipeScreen(recipes: widget.recipes),
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
        ],
      ),
    );
  }
}
