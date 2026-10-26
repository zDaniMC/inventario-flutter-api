import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/formatters.dart';
import '../models/resumen_inventario.dart';
import '../routes/app_routes.dart';
import '../services/producto_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estados.dart';
import '../widgets/stat_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ProductoService _servicio = ProductoService();
  late Future<ResumenInventario> _resumen;

  @override
  void initState() {
    super.initState();
    _resumen = _servicio.obtenerResumen();
  }

  Future<void> _recargar() async {
    final futuro = _servicio.obtenerResumen();
    setState(() => _resumen = futuro);
    try {
      await futuro;
    } catch (_) {}
  }

  Future<void> _irANuevoProducto() async {
    await context.push<bool>(AppRoutes.nuevoProducto);
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _recargar, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<ResumenInventario>(
        future: _resumen,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCargando(mensaje: 'Cargando indicadores...');
          }
          if (snapshot.hasError) {
            return EstadoError(mensaje: snapshot.error.toString(), alReintentar: _recargar);
          }

          final resumen = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Encabezado(colores: colores),
                const SizedBox(height: 20),
                StatCard(
                  titulo: 'Productos registrados',
                  valor: formatearNumero(resumen.totalProductos),
                  icono: Icons.category_rounded,
                  color: Colors.indigo,
                ),
                StatCard(
                  titulo: 'Unidades disponibles',
                  valor: formatearNumero(resumen.totalUnidades),
                  icono: Icons.inventory_rounded,
                  color: Colors.teal,
                ),
                StatCard(
                  titulo: 'Valor total del inventario',
                  valor: formatearMoneda(resumen.valorTotal),
                  icono: Icons.attach_money_rounded,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.productos),
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('Gestionar productos'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _irANuevoProducto,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar producto'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final ColorScheme colores;

  const _Encabezado({required this.colores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colores.primary, colores.tertiary]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_rounded, size: 48, color: colores.onPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('InvenTrack', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colores.onPrimary)),
                Text('Control de inventario en tiempo real', style: TextStyle(color: colores.onPrimary.withValues(alpha: 0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
