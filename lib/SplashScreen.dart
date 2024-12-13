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
          // Fondo de pantalla
          Image.asset(
            'assets/Inicio.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black); // Fondo negro si falla la imagen
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logotipo redondo
                CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage('assets/logo.png'),
                  onBackgroundImageError: (error, stackTrace) {
                    // Muestra un ícono de error si la imagen no se carga

                  },
                ),
                const SizedBox(height: 20),

                // Texto con efecto de borde
                _buildTextWithBorder(
                  'Bienvenido a Maestro Café',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),

                SizedBox(height: 10),

                _buildTextWithBorder(
                  'El mejor lugar para los amantes del café',
                  fontSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para crear texto con borde
  Widget _buildTextWithBorder(String text, {double fontSize = 16, FontWeight fontWeight = FontWeight.normal}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Borde del texto
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        // Texto relleno blanco
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
