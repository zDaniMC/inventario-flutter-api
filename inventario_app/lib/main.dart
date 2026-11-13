import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_router.dart';
import 'services/sesion_controller.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const InventarioApp());
  // Comprueba la sesión guardada mientras se muestra la pantalla de carga.
  SesionController.instance.restaurar();
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InvenTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      routerConfig: appRouter,
    );
  }
}
