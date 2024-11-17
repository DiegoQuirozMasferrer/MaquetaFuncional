import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _additionalFeedbackController = TextEditingController();

  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/feedback_questions.json');
      final Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        _questions = jsonResponse['usabilidad'] + jsonResponse['contenido'] + jsonResponse['compartir'];
      });
    } catch (e) {
      print('Error al cargar el archivo JSON: $e');
    }
  }

  Future<void> sendFeedbackEmail() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String group = _groupController.text;
      final String relation = _relationController.text;
      final String additionalFeedback = _additionalFeedbackController.text;

      // Construir las respuestas de la encuesta
      String feedbackText = 'Nombre: $name\nGrupo: $group\nRelación: $relation\n\n';
      for (var question in _questions) {
        feedbackText += '${question['titulo']}:\nRespuesta: ${question['valor']} estrellas\n\n';
      }

      // Agregar feedback adicional si está presente
      if (additionalFeedback.isNotEmpty) {
        feedbackText += 'Comentarios adicionales:\n$additionalFeedback\n';
      }

      final email = Email(
        body: feedbackText,
        subject: 'Feedback desde Maestro Café',
        recipients: ['dquiroz17@alumnos.utalca.cl'],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo enviado exitosamente')),
        );
        _clearForm();
      } catch (error) {
        print('Error al enviar el correo: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo enviar el correo')),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _groupController.clear();
    _relationController.clear();
    _additionalFeedbackController.clear();
    setState(() {
      for (var question in _questions) {
        question['valor'] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campos para Nombre, Grupo y Relación
              _buildTextField(_nameController, 'Nombre', 'Por favor, ingresa tu nombre'),
              SizedBox(height: 20),
              _buildTextField(_groupController, 'Grupo (piloto, trabajador del área, externo)', 'Por favor, ingresa tu grupo'),
              SizedBox(height: 20),
              _buildTextField(_relationController, 'Relación (amigo, colega, familia, etc.)', 'Por favor, ingresa tu relación'),
              SizedBox(height: 20),

              // Preguntas de la encuesta desde el JSON
              ..._questions.map((question) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['titulo'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: (question['valor'] as int).toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: '${question['valor']} ',
                            onChanged: (value) {
                              setState(() {
                                question['valor'] = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          question['min'],
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 10), // Espacio entre los textos
                        Text(
                          question['max'],
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                  ],
                );
              }).toList(),

              // Campo adicional para comentarios
              TextFormField(
                controller: _additionalFeedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Comentarios adicionales',
                  hintText: 'Escribe tus comentarios aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Botón para enviar feedback
              ElevatedButton.icon(
                onPressed: sendFeedbackEmail,
                icon: Icon(Icons.send),
                label: Text('Enviar Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un TextFormField con validación
  Widget _buildTextField(TextEditingController controller, String label, String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? validationMessage : null,
    );
  }
}
