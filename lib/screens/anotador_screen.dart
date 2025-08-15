import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:inasistapp/services/google_sheets_service.dart';
import 'package:intl/intl.dart';

class AnotadorScreen extends StatefulWidget {
  const AnotadorScreen({super.key});

  @override
  State<AnotadorScreen> createState() => _AnotadorScreenState();
}

class _AnotadorScreenState extends State<AnotadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedHora;

  List<String> _asignaturas = [];
  String? _selectedAsignatura;
  bool _loadingAsignaturas = true;

  List<String> _diarioOptions = [];
  String? _selectedDiarioOption;
  bool _loadingDiarioOptions = true;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Initialize with current date
    _fetchAsignaturas();
    _fetchDiarioOptions();
  }

  Future<void> _fetchAsignaturas() async {
    try {
      final response = await Dio()
          .get('https://app.iedeoccidente.com/ig/getAsignaturasAnotador.php');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _asignaturas =
              List<String>.from(response.data.map((e) => e.toString()));
          _loadingAsignaturas = false;
        });
      } else {
        throw Exception('Error al obtener las asignaturas');
      }
    } catch (e) {
      setState(() {
        _loadingAsignaturas = false;
      });
      // Handle error
      debugPrint(e.toString());
    }
  }

  Future<void> _fetchDiarioOptions() async {
    try {
      final response = await Dio()
          .get('https://app.iedeoccidente.com/ig/getOpcionesAnotador.php');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _diarioOptions =
              List<String>.from(response.data.map((e) => e.toString()));
          _loadingDiarioOptions = false;
        });
      } else {
        throw Exception('Error al obtener las opciones del diario');
      }
    } catch (e) {
      setState(() {
        _loadingDiarioOptions = false;
      });
      // Handle error
      debugPrint(e.toString());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  IconData _getAsignaturaIcon(String asignatura) {
    // You can add more specific icons based on asignatura names
    return Icons.book; // Default icon for asignatura
  }

  IconData _getHoraIcon(String hora) {
    // You can add more specific icons based on hora
    return Icons.access_time; // Default icon for hora
  }

  IconData _getDiarioOptionIcon(String option) {
    if (option.contains('Magistral')) {
      return Icons.school;
    } else if (option.contains('Taller práctico')) {
      return Icons.handyman;
    } else if (option.contains('Trabajo en grupo')) {
      return Icons.group;
    } else if (option.contains('Clase invertida')) {
      return Icons.flip;
    } else if (option.contains('Proyecto interdisciplinar')) {
      return Icons.lightbulb;
    } else if (option.contains('Evaluación')) {
      return Icons.assessment;
    } else {
      return Icons.description; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotador de Clases',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app), // Exit icon
            onPressed: () {
              Navigator.pop(context); // Pop the current screen
            },
            tooltip: 'Salir',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (_loadingAsignaturas)
                          const Center(child: CircularProgressIndicator())
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedAsignatura,
                            items: _asignaturas.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(_getAsignaturaIcon(value), size: 20),
                                    const SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedAsignatura = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Asignatura',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 12.0),
                            ),
                            validator: (value) =>
                                value == null ? 'Campo requerido' : null,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: _selectedDate == null
                                  ? ''
                                  : DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!)),
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Por favor seleccione una fecha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedHora,
                          items: ['1', '2', '3', '4'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(_getHoraIcon(value), size: 20),
                                  const SizedBox(width: 8),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedHora = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Horas de Clase',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          validator: (value) =>
                              value == null ? 'Campo requerido' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Tema de la clase',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_loadingDiarioOptions)
                          const Center(child: CircularProgressIndicator())
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedDiarioOption,
                            isExpanded: true,
                            items: _diarioOptions.asMap().entries.expand((entry) {
                              int index = entry.key;
                              String value = entry.value;
                              Color textColor = index % 2 == 0
                                  ? Colors.black
                                  : Colors.grey[700]!; // Alternating colors

                              List<DropdownMenuItem<String>> items = [
                                DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0), // Add horizontal padding
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7, // Adjust width as needed
                                      child: Row( // Use Row to display icon and text
                                        children: [
                                          Icon(_getDiarioOptionIcon(value), size: 20, color: textColor), // Icon
                                          const SizedBox(width: 8), // Space between icon and text
                                          Expanded( // Use Expanded to allow text to take remaining space
                                            child: Text(
                                              value, // Display full text in the dropdown list
                                              overflow: TextOverflow
                                                  .visible, // Allow text to be visible
                                              maxLines: null, // Allow unlimited lines
                                              style: TextStyle(
                                                  color:
                                                      textColor), // Apply alternating color
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ];

                              if (index < _diarioOptions.length - 1) {
                                items.add(
                                  const DropdownMenuItem<String>(
                                    enabled: false, // Make the divider unselectable
                                    value: null, // No value for the divider
                                    child: Divider(
                                        height: 1,
                                        thickness: 1), // The actual divider
                                  ),
                                );
                              }
                              return items;
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return _diarioOptions.map<Widget>((String item) {
                                return Text(
                                  item.length > 50
                                      ? '${item.substring(0, 50)}...'
                                      : item, // Truncate for selected display
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              }).toList();
                            },
                            onChanged: (newValue) {
                              setState(() {
                                _selectedDiarioOption = newValue;
                                if (newValue != null) {
                                  _contentController.text =
                                      newValue; // Copy to text field
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Seleccione una opción de Diario de campo',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 12.0),
                            ),
                            validator: (value) =>
                                value == null ? 'Campo requerido' : null,
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: 'Diario de campo (editable)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          maxLines: null, // Allows multiple lines
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el contenido del diario';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Increased space before button
                ElevatedButton(
                  onPressed: _isSending ? null : _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text(
                          'Guardar',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      try {
        final sheetsService = GoogleSheetsService(
            '1wN7lp7lOGyxKYIUJ9TU89N9knnJjX2Z_TfsOUg48QpQ', 'Anotador');
        await sheetsService.init();

        final row = [
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // 1. Marca temporal
          _selectedAsignatura, // 2. Asignatura
          DateFormat('yyyy-MM-dd').format(_selectedDate!), // 3. Fecha
          _selectedHora, // 4. Horas
          _titleController.text, // 5. Tema de la clase
          _contentController.text, // 6. Diario de campo
        ];

        await sheetsService.appendRow(row);

        if (!mounted) return;
        _showSuccessDialog(context);
        _clearForm();
      } catch (e) {
        if (!mounted) return;
        _showErrorDialog(context, 'Error al guardar la nota: $e');
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      _selectedAsignatura = null;
      _titleController.clear();
      _selectedDiarioOption = null;
      _contentController.clear(); // Clear the editable text field
      _selectedDate = null;
      _selectedHora = null;
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Éxito'),
            ],
          ),
          content: const Text('Nota guardada correctamente.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
