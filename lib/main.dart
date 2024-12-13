import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'Home.dart';
import 'RecipeNotifier.dart';
import 'ThemeNotifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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