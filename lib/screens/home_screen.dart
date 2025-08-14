import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:inasistapp/screens/anotador_screen.dart';
import 'package:inasistapp/screens/inasistencias_screen.dart';
import 'package:inasistapp/screens/convivencia_screen.dart'; // New import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Libro Docente',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app), // Exit icon
            onPressed: () {
              SystemNavigator.pop(); // Exit the application
            },
            tooltip: 'Salir',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment_late, color: Colors.white),
                label: const Text('Inasistencias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InasistenciasScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.note_add, color: Colors.white),
                label: const Text('Anotador de Clases'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnotadorScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.people, color: Colors.white), // Icon for Convivencia
                label: const Text('Convivencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConvivenciaScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
