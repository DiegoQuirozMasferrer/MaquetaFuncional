import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(recipes: [])),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo para la pantalla de presentación
          Image.asset(
            'assets/Inicio.jpg', // Cambia por la ruta de tu imagen
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la aplicación
              const CircleAvatar(
                radius: 80.0,
                backgroundImage: AssetImage('assets/logo.png'), // Cambia por la ruta de tu logo
              ),
              const SizedBox(height: 20),
              // Texto principal con bordes negros
              Stack(
                children: [
                  // Borde del texto
                  Text(
                    'Bienvenido a Maestro Café',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
                        ..color = Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Texto relleno blanco
                  Text(
                    'Bienvenido a Maestro Café',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Mensaje adicional con bordes negros
              Stack(
                children: [
                  // Borde del texto adicional
                  Text(
                    'El mejor lugar para los amantes del café',
                    style: TextStyle(
                      fontSize: 16,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Texto adicional relleno blanco
                  Text(
                    'El mejor lugar para los amantes del café',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
