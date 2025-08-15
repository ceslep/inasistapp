import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:inasistapp/services/google_sheets_service.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentName;
  final String grade;

  const StudentDetailsScreen({
    super.key,
    required this.studentName,
    required this.grade,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, List<String>> _absencesBySubject = {};
  final Map<String, Color> _subjectColors = {};

  @override
  void initState() {
    super.initState();
    _fetchAbsences();
  }

  Future<void> _fetchAbsences() async {
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
        final List<List<dynamic>> dataRows = rows.sublist(1);
        Map<String, List<String>> absences = {};

        for (var row in dataRows) {
          if (row.length > 8 &&
              row[8] != null &&
              row[8].toString() == widget.studentName) {
            if (row.length > 4 &&
                row[4] != null &&
                row.isNotEmpty &&
                row[0] != null) {
              debugPrint(row.toString());
              final subject = row[4].toString();
              final dateValue = row[2];
              DateTime date = DateTime(1899, 12, 30).add(Duration(days: (dateValue is num ? dateValue.toInt() : int.parse(dateValue.toString()))));
              final formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'es_CO').format(date);
              if (absences.containsKey(subject)) {
                absences[subject]!.add(formattedDate);
              } else {
                absences[subject] = [formattedDate];
              }
            }
          }
        }
        final sortedKeys = absences.keys.toList()..sort();
        final sortedAbsences = LinkedHashMap<String, List<String>>.fromIterable(
          sortedKeys,
          key: (k) => k,
          value: (k) => absences[k]!,
        );
        _absencesBySubject = sortedAbsences;
      }
    } on DioException catch (e) {
      _error = 'Error de red: ${e.message}';
    } catch (e) {
      debugPrint('Error fetching absences: $e');
      _error = 'Error al cargar las inasistencias: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PieChartSectionData> _getSections() {
    if (_absencesBySubject.isEmpty) {
      return [];
    }

    final totalAbsences = _absencesBySubject.values.fold<int>(0, (sum, dates) => sum + dates.length);
    if (totalAbsences == 0) {
      return [];
    }

    List<Color> availableColors = [
      Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.purple,
      Colors.orange, Colors.cyan, Colors.pink, Colors.teal, Colors.indigo,
    ];
    int colorIndex = 0;

    _subjectColors.clear(); // Clear previous colors
    for (var subject in _absencesBySubject.keys) {
      _subjectColors[subject] = availableColors[colorIndex % availableColors.length];
      colorIndex++;
    }

    return _absencesBySubject.entries.map((entry) {
      final subject = entry.key;
      final count = entry.value.length;
      final percentage = (count / totalAbsences) * 100;
      final color = _subjectColors[subject]!;

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _buildBadge(subject, color),
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName,
            style: const TextStyle(color: Colors.white)),
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
                          onPressed: _fetchAbsences,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _absencesBySubject.isEmpty
                  ? const Center(
                      child: Text(
                          'No se encontraron inasistencias para este estudiante.'),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _absencesBySubject.length,
                              itemBuilder: (context, index) {
                                final subject =
                                    _absencesBySubject.keys.elementAt(index);
                                final dates = _absencesBySubject[subject]!;
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ExpansionTile(
                                    title: Text(subject,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    trailing: Text(
                                        '${dates.length} inasistencias',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.red)),
                                    children: dates
                                        .map((date) =>
                                            ListTile(title: Text(date)))
                                        .toList(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Distribución de Inasistencias por Asignatura',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: _getSections(),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _absencesBySubject.entries.map((entry) {
                                final subject = entry.key;
                                final count = entry.value.length;
                                final totalAbsences = _absencesBySubject.values.fold<int>(0, (sum, dates) => sum + dates.length);
                                final percentage = (count / totalAbsences) * 100;
                                final color = _subjectColors[subject]!;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('$subject: $count inasistencias (${percentage.toStringAsFixed(1)}%)'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}