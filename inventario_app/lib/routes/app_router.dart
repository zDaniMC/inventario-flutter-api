import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/dashboard_view.dart';
import '../views/producto_detalle_view.dart';
import '../views/producto_form_view.dart';
import '../views/productos_view.dart';
import 'app_routes.dart';

int _leerId(GoRouterState state) => int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: AppRoutes.productos,
      name: 'productos',
      builder: (context, state) => const ProductosView(),
      routes: [
        GoRoute(
          path: 'nuevo',
          name: 'nuevo-producto',
          builder: (context, state) => const ProductoFormView(),
        ),
        GoRoute(
          path: ':id',
          name: 'detalle-producto',
          builder: (context, state) => ProductoDetalleView(productoId: _leerId(state)),
          routes: [
            GoRoute(
              path: 'editar',
              name: 'editar-producto',
              builder: (context, state) => ProductoFormView(productoId: _leerId(state)),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Página no encontrada')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.go(AppRoutes.dashboard),
        child: const Text('Volver al inicio'),
      ),
    ),
  ),
);
