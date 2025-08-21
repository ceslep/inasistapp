import 'package:flutter/material.dart';
import 'package:inasistapp/screens/student_details_screen.dart';
import 'package:inasistapp/screens/grupos_screen.dart'; // Import for GruposScreen
import 'package:inasistapp/services/google_sheets_service.dart';
import 'package:dio/dio.dart'; // Import Dio for potential network errors

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  List<Map<String, String>> _students = [];
  List<Map<String, String>> _filteredStudents = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sheetsService = GoogleSheetsService();
      await sheetsService.init(); // It will load from shared_preferences

      final List<List<dynamic>> rows = await sheetsService.getRows();

      if (rows.isNotEmpty) {
        final List<List<dynamic>> dataRows = rows.sublist(1);
        Set<String> uniqueStudentIdentifiers = {};
        List<Map<String, String>> studentDetails = [];

        for (var row in dataRows) {
          if (row.length > 8 &&
              row[8] != null &&
              row.length > 6 &&
              row[6] != null) {
            final studentName = row[8].toString();
            final grade = row[6].toString();
            final identifier = "$studentName-$grade";

            if (uniqueStudentIdentifiers.add(identifier)) {
              studentDetails.add({'name': studentName, 'grade': grade});
            }
          }
        }

        studentDetails.sort((a, b) => a['name']!.compareTo(b['name']!));
        _students = studentDetails;
        _filteredStudents = _students;
      } else {
        _students = [];
        _filteredStudents = [];
      }
    } on DioException catch (e) {
      _error = 'Error de red: ${e.message}';
    } catch (e) {
      debugPrint('Error fetching students: $e');
      _error =
          'Error al cargar estudiantes. Verifique la conexión, los permisos de la hoja de cálculo o el formato de los datos: $e';
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        final studentName = student['name']?.toLowerCase() ?? '';
        final grade = student['grade']?.toLowerCase() ?? '';
        return studentName.contains(query) || grade.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
        ),
        title: const Text(
          'Estadísticas de Estudiantes',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GruposScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o grado...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color.fromRGBO(255, 255, 255, 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchStudents,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _filteredStudents.isEmpty
                  ? const Center(child: Text('No se encontraron estudiantes.'))
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        final studentName =
                            student['name'] ?? 'Nombre no disponible';
                        final grade = student['grade'] ?? 'Grado no disponible';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.blueAccent),
                            title: Text(studentName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(grade,
                                style: const TextStyle(fontSize: 12)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsScreen(
                                    studentName: studentName,
                                    grade: grade,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
