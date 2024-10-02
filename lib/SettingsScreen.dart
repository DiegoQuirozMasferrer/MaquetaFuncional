import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ThemeNotifier.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Color> colors = [Colors.brown, Colors.blue, Colors.red, Colors.green];
  final List<String> fontFamilies = ['Roboto', 'Lobster', 'Courier', 'Times New Roman'];

  bool _isDarkMode = false;
  Color _selectedColor = Colors.brown;

  String _selectedFont = 'Roboto';

  @override
  void initState() {
    super.initState();

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _isDarkMode = themeNotifier.isDarkMode;
    _selectedColor = themeNotifier.primaryColor;

    _selectedFont = themeNotifier.fontFamily;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuraciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Modo Oscuro
            ListTile(
              title: Text('Modo Oscuro'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              ),
            ),
            Divider(),


            ListTile(
              title: Text('Color Principal'),
              trailing: DropdownButton<Color>(
                value: _selectedColor,
                onChanged: (Color? newColor) {
                  setState(() {
                    _selectedColor = newColor!;
                  });


                  final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
                  themeNotifier.setPrimaryColor(_selectedColor);
                },
                items: colors.map((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 24,
                      height: 24,
                      color: color,
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(),




            ListTile(
              title: Text('Tipografía'),
              trailing: DropdownButton<String>(
                value: _selectedFont,
                onChanged: (String? newFont) {
                  setState(() {
                    _selectedFont = newFont!;
                  });
                },
                items: fontFamilies.map((String font) {
                  return DropdownMenuItem<String>(
                    value: font,
                    child: Text(
                      font,
                      style: TextStyle(fontFamily: font),
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(),


            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Aplicar los cambios al ThemeNotifier
                  themeNotifier.toggleDarkMode(_isDarkMode);
                  themeNotifier.setPrimaryColor(_selectedColor);

                  themeNotifier.setFontFamily(_selectedFont);


                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Configuraciones aplicadas')),
                  );

                  // Volver a la pantalla anterior
                  Navigator.pop(context);
                },
                child: Text(
                  'Aplicar Cambios',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: themeNotifier.primaryColor,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
