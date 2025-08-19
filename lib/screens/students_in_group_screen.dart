import 'package:flutter/material.dart';
import 'package:inasistapp/services/google_sheets_service.dart';
import 'package:dio/dio.dart';
import 'package:inasistapp/screens/student_details_screen.dart';

class StudentsInGroupScreen extends StatefulWidget {
  final String groupName;

  const StudentsInGroupScreen({super.key, required this.groupName});

  @override
  State<StudentsInGroupScreen> createState() => _StudentsInGroupScreenState();
}

class _StudentsInGroupScreenState extends State<StudentsInGroupScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, String>> _studentsInGroup = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentsInGroup();
  }

  Future<void> _fetchStudentsInGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sheetsService = GoogleSheetsService(
          '1wN7lp7lOGyxKYIUJ9TU89N9knnJjX2Z_TfsOUg48QpQ', 'Inasistencias');
      await sheetsService.init();

      final List<List<dynamic>> rows = await sheetsService.getRows();

      if (rows.isNotEmpty) {
        final List<List<dynamic>> dataRows = rows.sublist(1); // Skip header row
        List<Map<String, String>> tempStudents = [];
        Set<String> uniqueStudentIdentifiers = {};

        for (var row in dataRows) {
          // Assuming student name is at index 8 and grade (group) is at index 6
          if (row.length > 8 &&
              row[8] != null &&
              row.length > 6 &&
              row[6] != null) {
            final studentName = row[8].toString();
            final grade = row[6].toString();
            final identifier = "$studentName-$grade";

            if (grade == widget.groupName &&
                uniqueStudentIdentifiers.add(identifier)) {
              tempStudents.add({'name': studentName, 'grade': grade});
            }
          }
        }
        tempStudents.sort((a, b) => a['name']!.compareTo(b['name']!));
        _studentsInGroup = tempStudents;
      } else {
        _studentsInGroup = [];
      }
    } on DioException catch (e) {
      _error = 'Error de red: ${e.message}';
    } catch (e) {
      debugPrint('Error fetching students in group: $e');
      _error =
          'Error al cargar estudiantes. Verifique la conexión, los permisos de la hoja de cálculo o el formato de los datos: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estudiantes en ${widget.groupName}',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                          onPressed: _fetchStudentsInGroup,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _studentsInGroup.isEmpty
                  ? const Center(
                      child:
                          Text('No se encontraron estudiantes en este grupo.'))
                  : ListView.builder(
                      itemCount: _studentsInGroup.length,
                      itemBuilder: (context, index) {
                        final student = _studentsInGroup[index];
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
