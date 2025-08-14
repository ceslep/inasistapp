
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inasistapp/widgets/home_body.dart';

class InasistenciasScreen extends StatefulWidget {
  const InasistenciasScreen({super.key});

  @override
  State<InasistenciasScreen> createState() => _InasistenciasScreenState();
}

class _InasistenciasScreenState extends State<InasistenciasScreen> {
  final GlobalKey<HomeBodyState> homeBodyKey = GlobalKey<HomeBodyState>();
  bool _appBarIsSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Inasistencias',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              SystemNavigator.pop();
            },
          ),
          IconButton(
            icon: _appBarIsSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              homeBodyKey.currentState?.submitAbsenceData();
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: HomeBody(
        key: homeBodyKey,
        onSendingStateChanged: (isSending) {
          setState(() {
            _appBarIsSending = isSending;
          });
        },
      ),
    );
  }
}
