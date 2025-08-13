import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response =
        await dio.get('http://app.iedeoccidente.com/ig/getprofes.php');
    if (response.statusCode == 200) {
      final List<dynamic> data =
          response.data is String ? json.decode(response.data) : response.data;
      print('Docentes recibidos:');
      for (var docente in data) {
        print(docente);
      }
    } else {
      print('Error al obtener los docentes: ${response.statusCode}');
    }
  } catch (e) {
    print('Error de conexión: $e');
  }
}
