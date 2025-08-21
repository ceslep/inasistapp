
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _spreadsheetIdController = TextEditingController();
  final _inasistenciasSheetController = TextEditingController();
  final _anotadorSheetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _spreadsheetIdController.text = prefs.getString('spreadsheetId') ?? '';
      _inasistenciasSheetController.text = prefs.getString('inasistenciasSheet') ?? 'Inasistencias';
      _anotadorSheetController.text = prefs.getString('anotadorSheet') ?? 'Anotador';
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('spreadsheetId', _spreadsheetIdController.text);
      await prefs.setString('inasistenciasSheet', _inasistenciasSheetController.text);
      await prefs.setString('anotadorSheet', _anotadorSheetController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _spreadsheetIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de la Hoja de Cálculo',
                  hintText: 'Ingresa el ID de tu Google Sheet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _inasistenciasSheetController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la hoja de Inasistencias',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anotadorSheetController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la hoja del Anotador',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
