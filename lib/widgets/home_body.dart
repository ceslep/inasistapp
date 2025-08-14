// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inasistapp/services/google_sheets_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dio/dio.dart';

// Paleta de colores profesional
const Color primaryColor = Color(0xFF0D47A1); // Azul oscuro
const Color accentColor = Color(0xFFFFC107); // Ámbar
const Color backgroundColor = Color(0xFFF5F5F5); // Gris claro
const Color cardColor = Colors.white;
const Color textColor = Color(0xFF333333);
const Color successColor = Color(0xFF4CAF50);
const Color errorColor = Color(0xFFD32F2F);

class HomeBody extends StatefulWidget {
  const HomeBody({super.key, this.onSendingStateChanged});

  final ValueChanged<bool>? onSendingStateChanged;

  @override
    State<HomeBody> createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  List<String> docentes = [];
  List<String> materias = [];
  bool loading = true;
  bool _isSending = false;
  String? error;

  Map<String, List<String>> estudiantesPorGrado = {};
  List<String> grados = [];
  String? gradoSeleccionado;
  Set<String> estudiantesSeleccionados = {};
  Map<String, String> motivoPorEstudiante = {};
  String? docenteSeleccionado;
  String? materiaSeleccionada;
  String? horaSeleccionada;
  DateTime selectedDate = DateTime.now();

  final List<String> horas =
      List.generate(4, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    fetchData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: const ColorScheme.light(primary: primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  static const String _baseUrl = 'http://app.iedeoccidente.com/ig';
  static const String _docentesUrl = '$_baseUrl/getprofes.php';
  static const String _materiasUrl = '$_baseUrl/getMaterias.php';
  static const String _estudiantesUrl = '$_baseUrl/getEstudiantes.php';

  Future<void> fetchData() async {
    try {
      final dio = Dio();

      final responseDocentes = await dio.get(_docentesUrl);
      if (responseDocentes.statusCode == 200 && responseDocentes.data is List) {
        docentes =
            List<String>.from(responseDocentes.data.map((e) => e.toString()));
      } else {
        throw Exception('Error al obtener los docentes');
      }

      final responseMaterias = await dio.get(_materiasUrl);
      if (responseMaterias.statusCode == 200 && responseMaterias.data is List) {
        materias = List<String>.from(
            responseMaterias.data.map((e) => e['materia'].toString()));
      } else {
        throw Exception('Error al obtener las materias');
      }

      final responseEstudiantes = await dio.get(_estudiantesUrl);
      if (responseEstudiantes.statusCode == 200 &&
          responseEstudiantes.data is List) {
        final rawData = responseEstudiantes.data;
        estudiantesPorGrado.clear();
        for (var item in rawData) {
          if (item is Map<String, dynamic> &&
              item.containsKey('nombre') &&
              item.containsKey('grado')) {
            final nombre = item['nombre']?.toString() ?? '';
            final grado = item['grado']?.toString() ?? '';
            if (nombre.isNotEmpty && grado.isNotEmpty) {
              if (!estudiantesPorGrado.containsKey(grado)) {
                estudiantesPorGrado[grado] = [];
              }
              estudiantesPorGrado[grado]!.add(nombre);
            }
          }
        }
        grados = estudiantesPorGrado.keys.toList()
          ..sort((a, b) {
            final aNum = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            final bNum = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            final aChar = a.replaceAll(RegExp(r'[0-9]'), '');
            final bChar = b.replaceAll(RegExp(r'[0-9]'), '');

            if (aNum != bNum) {
              return aNum.compareTo(bNum);
            } else {
              return aChar.compareTo(bChar);
            }
          });
      } else {
        throw Exception('Error al obtener los estudiantes');
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        loading = false;
      });
    }
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
              Icon(Icons.check_circle, color: successColor),
              SizedBox(width: 10),
              Text('Éxito'),
            ],
          ),
          content: const Text('Inasistencia enviada correctamente.'),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Aceptar', style: TextStyle(color: primaryColor)),
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
              Icon(Icons.error, color: errorColor),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Aceptar', style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Builder(
        builder: (context) {
          if (loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
                  SizedBox(height: 16),
                  Text('Cargando datos...', style: TextStyle(color: textColor)),
                ],
              ),
            );
          }
          if (error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: errorColor, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: errorColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed: () {
                        setState(() {
                          loading = true;
                          error = null;
                        });
                        fetchData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoClaseSection(context),
                  const SizedBox(height: 24),
                  _buildEstudiantesSection(context),
                  const SizedBox(height: 24),
                  _buildEnviarButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoClaseSection(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: textColor, bodyColor: textColor);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información de la Clase',
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    DocenteForm(
                      docentes: docentes,
                      value: docenteSeleccionado,
                      onChanged: (value) {
                        setState(() {
                          docenteSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    MateriaForm(
                      materias: materias,
                      value: materiaSeleccionada,
                      onChanged: (value) {
                        setState(() {
                          materiaSeleccionada = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DateForm(
                      selectedDate: selectedDate,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                    HoraForm(
                      horas: horas,
                      value: horaSeleccionada,
                      onChanged: (value) {
                        setState(() {
                          horaSeleccionada = value;
                        });
                      },
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información de la Clase',
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        DocenteForm(
                          docentes: docentes,
                          value: docenteSeleccionado,
                          onChanged: (value) {
                            setState(() {
                              docenteSeleccionado = value;
                            });
                          },
                        ),
                        MateriaForm(
                          materias: materias,
                          value: materiaSeleccionada,
                          onChanged: (value) {
                            setState(() {
                              materiaSeleccionada = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        DateForm(
                          selectedDate: selectedDate,
                          onTap: () => _selectDate(context),
                        ),
                        HoraForm(
                          horas: horas,
                          value: horaSeleccionada,
                          onChanged: (value) {
                            setState(() {
                              horaSeleccionada = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEstudiantesSection(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: textColor, bodyColor: textColor);

    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selección de Estudiantes',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccione el grado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school_outlined, color: primaryColor),
              ),
              value: gradoSeleccionado,
              items: grados
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Row(
                          children: [
                            Icon(Icons.groups, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text('Grado $g'),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  gradoSeleccionado = value;
                  estudiantesSeleccionados.clear();
                  motivoPorEstudiante.clear();
                });
              },
            ),
            if (gradoSeleccionado != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Estudiantes de Grado $gradoSeleccionado',
                  style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildEstudiantesList(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEstudiantesList() {
    final estudiantes = estudiantesPorGrado[gradoSeleccionado]!;
    if (estudiantes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No hay estudiantes en este grado.',
              style: TextStyle(color: textColor)),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: estudiantes.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final estudiante = estudiantes[index];
          final isSelected = estudiantesSeleccionados.contains(estudiante);
          return Column(
            children: [
              CheckboxListTile(
                secondary:
                    const Icon(Icons.person_outline, color: primaryColor),
                title: Text(estudiante,
                    style: const TextStyle(color: textColor)),
                value: isSelected,
                activeColor: primaryColor,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      estudiantesSeleccionados.add(estudiante);
                      motivoPorEstudiante.putIfAbsent(
                          estudiante, () => 'Sin excusa');
                    } else {
                      estudiantesSeleccionados.remove(estudiante);
                      motivoPorEstudiante.remove(estudiante);
                    }
                  });
                },
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(72.0, 0, 16.0, 16.0),
                  child: _buildMotivoDropdown(estudiante),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMotivoDropdown(String estudiante) {
    return DropdownButtonFormField<String>(
      value: motivoPorEstudiante[estudiante] ?? 'Sin excusa',
      decoration: const InputDecoration(
        labelText: 'Motivo de la inasistencia',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        _buildMotivoMenuItem(
          'Sin excusa',
          'Sin excusa',
          Icons.cancel_outlined,
          Colors.red,
        ),
        _buildMotivoMenuItem(
          'Retardo',
          'Retardo',
          Icons.access_time,
          Colors.orange,
        ),
        _buildMotivoMenuItem(
          'Excusa',
          'Con Excusa',
          Icons.note_alt_outlined,
          Colors.blue,
        ),
        _buildMotivoMenuItem(
          'Permiso',
          'Permiso',
          Icons.check_circle_outline,
          Colors.green,
        ),
      ],
      onChanged: (motivo) {
        setState(() {
          motivoPorEstudiante[estudiante] = motivo ?? 'Sin excusa';
        });
      },
    );
  }

  DropdownMenuItem<String> _buildMotivoMenuItem(
      String value, String text, IconData icon, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildEnviarButton(BuildContext context) {
    final bool canSubmit = docenteSeleccionado != null &&
        materiaSeleccionada != null &&
        horaSeleccionada != null &&
        gradoSeleccionado != null &&
        estudiantesSeleccionados.isNotEmpty;

    return ElevatedButton.icon(
      icon: _isSending
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.send, color: Colors.white),
      label: Text(_isSending ? 'Enviando...' : 'Enviar Inasistencias'),
      style: ElevatedButton.styleFrom(
        backgroundColor: canSubmit ? primaryColor : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: (canSubmit && !_isSending)
          ? () => submitAbsenceData()
          : null,
    );
  }

  Future<void> submitAbsenceData() async {
    if (_isSending) return; // Prevent multiple submissions

    setState(() {
      _isSending = true;
    });

    try {
      final sheetsService = GoogleSheetsService(
          '1wN7lp7lOGyxKYIUJ9TU89N9knnJjX2Z_TfsOUg48QpQ',
          'Inasistencias');
      await sheetsService.init();

      for (final estudiante in estudiantesSeleccionados) {
        final row = [
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Timestamp for Column A
          docenteSeleccionado,
          DateFormat('yyyy-MM-dd').format(selectedDate),
          '${horaSeleccionada!} ${horaSeleccionada == '1' ? 'hora' : 'horas'}',
          materiaSeleccionada,
          motivoPorEstudiante[estudiante] ?? 'Sin excusa',
          gradoSeleccionado,
          '', // Columna H vacía
          estudiante,
        ];
        await sheetsService.appendRow(row);
      }

      _showSuccessDialog(context);
      _clearForm();
    } catch (e) {
      _showErrorDialog(
          context, 'Error al enviar a Google Sheets: $e');
    } finally {
      setState(() {
        _isSending = false;
        widget.onSendingStateChanged?.call(false);
      });
    }
  }

  void _clearForm() {
    setState(() {
      docenteSeleccionado = null;
      materiaSeleccionada = null;
      horaSeleccionada = null;
      gradoSeleccionado = null;
      estudiantesSeleccionados.clear();
      motivoPorEstudiante.clear();
      selectedDate = DateTime.now();
    });
  }
}

class DocenteForm extends StatelessWidget {
  final List<String> docentes;
  final String? value;
  final ValueChanged<String?>? onChanged;
  const DocenteForm(
      {super.key, required this.docentes, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Docente',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school_outlined, color: primaryColor),
      ),
      value: value,
      items: docentes.isEmpty
          ? [
              const DropdownMenuItem(
                  value: null, child: Text('No hay docentes disponibles'))
            ]
          : docentes
              .map((docente) => DropdownMenuItem(
                    value: docente,
                    child: Row(
                      children: [
                        Icon(Icons.class_, color: primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(docente),
                      ],
                    ),
                  ))
              .toList(),
      onChanged: docentes.isEmpty ? null : onChanged,
    );
  }
}

class MateriaForm extends StatelessWidget {
  final List<String> materias;
  final String? value;
  final ValueChanged<String?>? onChanged;
  const MateriaForm(
      {super.key, required this.materias, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Materia',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.menu_book_outlined, color: primaryColor),
      ),
      value: value,
      items: materias.isEmpty
          ? [
              const DropdownMenuItem(
                  value: null, child: Text('No hay materias disponibles'))
            ]
          : materias
              .map((materia) => DropdownMenuItem(
                    value: materia,
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories, color: successColor, size: 20),
                        SizedBox(width: 8),
                        Text(materia),
                      ],
                    ),
                  ))
              .toList(),
      onChanged: materias.isEmpty ? null : onChanged,
    );
  }
}

class HoraForm extends StatelessWidget {
  final List<String> horas;
  final String? value;
  final ValueChanged<String?>? onChanged;
  const HoraForm({super.key, required this.horas, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Hora',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time_outlined, color: primaryColor),
      ),
      value: value,
      items: horas
          .map((hora) => DropdownMenuItem(
                value: hora,
                child: Text('$hora ${hora == '1' ? 'hora' : 'horas'}'),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class DateForm extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DateForm({super.key, required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today_outlined, color: primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              DateFormat.yMd('es').format(selectedDate),
              style: const TextStyle(color: textColor),
            ),
            const Icon(Icons.arrow_drop_down, color: primaryColor),
          ],
        ),
      ),
    );
  }
}
