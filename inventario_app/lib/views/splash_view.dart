import 'package:flutter/material.dart';

/// Pantalla mostrada mientras se verifica la sesión guardada.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_rounded, size: 64, color: colores.primary),
            const SizedBox(height: 16),
            const Text('InvenTrack', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('Verificando sesión...'),
          ],
        ),
      ),
    );
  }
}
