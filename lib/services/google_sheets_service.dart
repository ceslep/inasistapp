import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';

class GoogleSheetsService {
  final String _spreadsheetId;
  final String _worksheetName;
  GSheets? _gsheets;
  Worksheet? _worksheet;

  GoogleSheetsService(this._spreadsheetId, this._worksheetName);

  Future<void> init() async {
    try {
      final credentialsJson =
          await rootBundle.loadString('assets/serviceaccount.json');
      _gsheets = GSheets(credentialsJson);
      final spreadsheet = await _gsheets!.spreadsheet(_spreadsheetId);
      _worksheet = spreadsheet.worksheetByTitle(_worksheetName);
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing Google Sheets service: $e');
      rethrow;
    }
  }

  Future<bool> appendRow(List<dynamic> rowData) async {
    try {
      if (_gsheets == null) {
        await init();
      }
      if (_worksheet == null) return false;
      return await _worksheet!.values.appendRow(rowData);
    } catch (e) {
      // ignore: avoid_print
      print('Error appending row to Google Sheets: $e');
      return false;
    }
  }
}
