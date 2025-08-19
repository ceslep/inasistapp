import 'package:flutter/material.dart';
import 'package:inasistapp/services/google_sheets_service.dart';
import 'package:dio/dio.dart';
import 'package:inasistapp/screens/students_in_group_screen.dart';

class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});

  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, int> _inasistenciasPorGrupo = {};

  @override
  void initState() {
    super.initState();
    _fetchGroupStatistics();
  }

  Future<void> _fetchGroupStatistics() async {
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
        Map<String, int> tempInasistenciasPorGrupo = {};

        for (var row in dataRows) {
          // Assuming 'grade' (group) is at index 6, similar to estadisticas_screen.dart
          if (row.length > 6 && row[6] != null) {
            final group = row[6].toString();
            tempInasistenciasPorGrupo.update(group, (value) => value + 1,
                ifAbsent: () => 1);
          }
        }
        _inasistenciasPorGrupo = tempInasistenciasPorGrupo;
      } else {
        _inasistenciasPorGrupo = {};
      }
    } on DioException catch (e) {
      _error = 'Error de red: ${e.message}';
    } catch (e) {
      debugPrint('Error fetching group statistics: $e');
      _error =
          'Error al cargar estadísticas por grupo. Verifique la conexión, los permisos de la hoja de cálculo o el formato de los datos: $e';
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
        title: const Text(
          'Estadísticas por Grupo',
          style: TextStyle(
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
                          onPressed: _fetchGroupStatistics,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _inasistenciasPorGrupo.isEmpty
                  ? const Center(
                      child: Text('No se encontraron estadísticas por grupo.'))
                  : ListView.builder(
                      itemCount: _inasistenciasPorGrupo.length,
                      itemBuilder: (context, index) {
                        final group =
                            _inasistenciasPorGrupo.keys.elementAt(index);
                        final count =
                            _inasistenciasPorGrupo.values.elementAt(index);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text('Grupo: $group',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: Text('Inasistencias: $count'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentsInGroupScreen(
                                    groupName: group,
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
