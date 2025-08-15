import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() async {
  final dio = Dio();
  try {
    final response =
        await dio.get('http://app.iedeoccidente.com/ig/getprofes.php');
    if (response.statusCode == 200) {
      final List<dynamic> data =
          response.data is String ? json.decode(response.data) : response.data;
      debugPrint('Docentes recibidos:');
      for (var docente in data) {
        debugPrint(docente.toString());
      }
    } else {
      debugPrint('Error al obtener los docentes: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error de conexión: $e');
  }
}