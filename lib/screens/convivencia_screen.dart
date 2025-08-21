import 'package:flutter/material.dart';

class ConvivenciaScreen extends StatelessWidget {
  const ConvivenciaScreen({super.key});

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
        title: const Text('Convivencia'),
      ),
      body: const Center(
        child: Text('Convivencia Screen Content'),
      ),
    );
  }
}
