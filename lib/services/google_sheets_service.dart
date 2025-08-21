import 'dart:convert'; // Added
import 'package:flutter/services.dart' show rootBundle; // Added
import 'package:gsheets/gsheets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSheetsService {
  // Removed static const _credentials

  GSheets? _gsheets;
  Worksheet? _worksheet;
  String? _spreadsheetId;
  String? _worksheetTitle;

  GoogleSheetsService(); // No longer takes spreadsheetId and worksheetTitle in constructor

  Future<void> init(
      {String? customSpreadsheetId, String? customWorksheetTitle}) async {
    final prefs = await SharedPreferences.getInstance();
    _spreadsheetId = customSpreadsheetId ??
        prefs.getString('spreadsheetId') ??
        '1wN7lp7lOGyxKYIUJ9TU89N9knnJjX2Z_TfsOUg48QpQ'; // Default ID
    _worksheetTitle = customWorksheetTitle ??
        prefs.getString('inasistenciasSheet') ??
        'Inasistencias'; // Default sheet for Inasistencias

    if (_spreadsheetId == null || _worksheetTitle == null) {
      throw Exception(
          'Spreadsheet ID or Worksheet Title not provided and not found in settings.');
    }

    // Load credentials from assets
    final jsonString =
        await rootBundle.loadString('assets/serviceaccount.json');
    final _credentials = jsonDecode(jsonString);

    _gsheets = GSheets(_credentials);
    _worksheet = (await _gsheets!.spreadsheet(_spreadsheetId!))
        .worksheetByTitle(_worksheetTitle!); // Added ! for null safety
  }

  Future<void> appendRow(List<dynamic> row) async {
    if (_worksheet == null) {
      throw Exception('Worksheet not initialized. Call init() first.');
    }
    await _worksheet!.values.appendRow(row); // Added ! for null safety
  }

  Future<List<List<dynamic>>> getRows() async {
    if (_worksheet == null) {
      throw Exception('Worksheet not initialized. Call init() first.');
    }
    return await _worksheet!.values.allRows(); // Added ! for null safety
  }

  // New method to set the worksheet for Anotador
  Future<void> setAnotadorWorksheet() async {
    final prefs = await SharedPreferences.getInstance();
    _worksheetTitle = prefs.getString('anotadorSheet') ??
        'Anotador'; // Default sheet for Anotador
    if (_spreadsheetId == null || _worksheetTitle == null) {
      throw Exception(
          'Spreadsheet ID or Anotador Worksheet Title not provided and not found in settings.');
    }
    _worksheet = await (await _gsheets!.spreadsheet(_spreadsheetId!))
        .worksheetByTitle(_worksheetTitle!); // Added ! for null safety
  }
}
