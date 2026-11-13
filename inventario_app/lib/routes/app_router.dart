import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/sesion_controller.dart';
import '../views/dashboard_view.dart';
import '../views/login_view.dart';
import '../views/producto_detalle_view.dart';
import '../views/producto_form_view.dart';
import '../views/productos_view.dart';
import '../views/sesion_view.dart';
import '../views/splash_view.dart';
import 'app_routes.dart';

int _leerId(GoRouterState state) => int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  // Se reevalúa el redirect cada vez que cambia la sesión (login, logout, token expirado).
  refreshListenable: SesionController.instance,
  redirect: (context, state) {
    final ruta = state.matchedLocation;
    final enSplash = ruta == AppRoutes.splash;
    final enLogin = ruta == AppRoutes.login;

    switch (SesionController.instance.estado) {
      case EstadoSesion.verificando:
        return enSplash ? null : AppRoutes.splash;
      case EstadoSesion.sinSesion:
        // Sin sesión no se puede ver ninguna pantalla protegida.
        return enLogin ? null : AppRoutes.login;
      case EstadoSesion.autenticado:
        return (enSplash || enLogin) ? AppRoutes.dashboard : null;
    }
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.sesion,
      name: 'sesion',
      builder: (context, state) => const SesionView(),
    ),
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
