import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../routes/app_routes.dart';
import '../services/producto_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estados.dart';
import '../widgets/producto_card.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final ProductoService _servicio = ProductoService();
  late Future<List<Producto>> _productos;

  @override
  void initState() {
    super.initState();
    _productos = _servicio.obtenerProductos();
  }

  Future<void> _recargar() async {
    final futuro = _servicio.obtenerProductos();
    setState(() => _productos = futuro);
    try {
      await futuro;
    } catch (_) {}
  }

  Future<void> _abrir(String ruta) async {
    await context.push<bool>(ruta);
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(onPressed: _recargar, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(AppRoutes.nuevoProducto),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: FutureBuilder<List<Producto>>(
        future: _productos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCargando(mensaje: 'Cargando productos...');
          }
          if (snapshot.hasError) {
            return EstadoError(mensaje: snapshot.error.toString(), alReintentar: _recargar);
          }

          final productos = snapshot.data ?? [];
          if (productos.isEmpty) {
            return RefreshIndicator(
              onRefresh: _recargar,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  EstadoVacio(mensaje: 'Aún no hay productos. Presiona "Nuevo" para registrar uno.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: productos.length,
              itemBuilder: (context, indice) {
                final producto = productos[indice];
                return ProductoCard(
                  producto: producto,
                  alPresionar: () => _abrir(AppRoutes.detalleProducto(producto.id!)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
