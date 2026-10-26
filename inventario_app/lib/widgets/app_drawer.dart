import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final rutaActual = GoRouterState.of(context).uri.path;
    final colores = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colores.primary),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colores.onPrimary,
                  child: Icon(Icons.inventory_2_rounded, color: colores.primary, size: 30),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('InvenTrack', style: TextStyle(color: colores.onPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Gestión de inventario', style: TextStyle(color: colores.onPrimary.withValues(alpha: 0.85))),
                  ],
                ),
              ],
            ),
          ),
          _ItemMenu(
            icono: Icons.dashboard_rounded,
            titulo: 'Dashboard',
            seleccionado: rutaActual == AppRoutes.dashboard,
            alPresionar: () => context.go(AppRoutes.dashboard),
          ),
          _ItemMenu(
            icono: Icons.list_alt_rounded,
            titulo: 'Productos',
            seleccionado: rutaActual == AppRoutes.productos,
            alPresionar: () => context.go(AppRoutes.productos),
          ),
          _ItemMenu(
            icono: Icons.add_box_rounded,
            titulo: 'Registrar producto',
            seleccionado: rutaActual == AppRoutes.nuevoProducto,
            alPresionar: () => context.go(AppRoutes.nuevoProducto),
          ),
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final bool seleccionado;
  final VoidCallback alPresionar;

  const _ItemMenu({
    required this.icono,
    required this.titulo,
    required this.seleccionado,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      selected: seleccionado,
      onTap: () {
        Navigator.of(context).pop();
        alPresionar();
      },
    );
  }
}
