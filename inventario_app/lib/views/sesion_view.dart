import 'package:flutter/material.dart';

import '../services/sesion_controller.dart';
import '../services/sesion_storage.dart';
import '../widgets/app_drawer.dart';

/// Información de la sesión: usuario, estado, indicador de token y cierre de sesión.
class SesionView extends StatelessWidget {
  const SesionView({super.key});

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  String _formatoFecha(DateTime f) =>
      '${_dosDigitos(f.day)}/${_dosDigitos(f.month)}/${f.year} '
      '${_dosDigitos(f.hour)}:${_dosDigitos(f.minute)}:${_dosDigitos(f.second)}';

  @override
  Widget build(BuildContext context) {
    final sesion = SesionController.instance;
    final usuario = sesion.usuario;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi sesión')),
      drawer: const AppDrawer(),
      body: FutureBuilder<String?>(
        future: SesionStorage.leerToken(),
        builder: (context, snapshot) {
          final token = snapshot.data;
          final expira = token == null ? null : SesionStorage.expiracion(token);
          // Solo se muestran 6 caracteres del token; nunca su contenido completo.
          final indicador = token == null
              ? 'No hay token almacenado'
              : 'Almacenado de forma segura (${token.substring(0, 6)}••••••)';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colores.primaryContainer,
                    child: Text(
                      (usuario?.nombre.isNotEmpty ?? false) ? usuario!.nombre[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 24, color: colores.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?.nombre ?? 'Sin nombre',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(usuario?.email ?? 'Sin correo'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: const Text('Estado de autenticación'),
                      subtitle: Text(sesion.autenticado ? 'Sesión activa' : 'Sin sesión'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.key_outlined),
                      title: const Text('Token de acceso'),
                      subtitle: Text(indicador),
                    ),
                    if (expira != null)
                      ListTile(
                        leading: const Icon(Icons.timer_outlined),
                        title: const Text('El token expira'),
                        subtitle: Text(_formatoFecha(expira)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => SesionController.instance.logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          );
        },
      ),
    );
  }
}
