import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();

  Future<void> sendFeedbackEmail() async {
    final Email email = Email(
      body: _feedbackController.text,
      subject: 'Feedback para Maestro Café',
      recipients: ['diego.quiroz.12.14@gmail.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo enviado con éxito')),
      );
    } on PlatformException catch (e) {
      if (e.code == 'notAvailable') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró un cliente de correo en tu dispositivo.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar correo: ${e.message}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Feedback'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Tu Correo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Tu Opinión o Problema',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendFeedbackEmail,
              child: Text('Enviar Feedback'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
