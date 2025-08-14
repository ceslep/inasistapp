import 'package:flutter/material.dart';

class ConvivenciaScreen extends StatelessWidget {
  const ConvivenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convivencia'),
      ),
      body: const Center(
        child: Text('Convivencia Screen Content'),
      ),
    );
  }
}
