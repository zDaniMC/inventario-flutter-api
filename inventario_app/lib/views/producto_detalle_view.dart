import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/formatters.dart';
import '../models/producto.dart';
import '../routes/app_routes.dart';
import '../services/api_exception.dart';
import '../services/producto_service.dart';
import '../widgets/estados.dart';
import '../widgets/mensajes.dart';

class ProductoDetalleView extends StatefulWidget {
  final int productoId;

  const ProductoDetalleView({super.key, required this.productoId});

  @override
  State<ProductoDetalleView> createState() => _ProductoDetalleViewState();
}

class _ProductoDetalleViewState extends State<ProductoDetalleView> {
  final ProductoService _servicio = ProductoService();
  late Future<Producto> _producto;
  bool _eliminando = false;

  @override
  void initState() {
    super.initState();
    _producto = _servicio.obtenerProducto(widget.productoId);
  }

  void _recargar() {
    setState(() => _producto = _servicio.obtenerProducto(widget.productoId));
  }

  Future<void> _editar() async {
    final actualizado = await context.push<bool>(AppRoutes.editarProducto(widget.productoId));
    if (actualizado == true && mounted) _recargar();
  }

  Future<void> _eliminar(Producto producto) async {
    final confirmado = await confirmarAccion(
      context,
      titulo: 'Eliminar producto',
      mensaje: '¿Seguro que deseas eliminar "${producto.nombre}"? Esta acción no se puede deshacer.',
    );
    if (!confirmado || !mounted) return;

    setState(() => _eliminando = true);
    try {
      await _servicio.eliminarProducto(widget.productoId);
      if (!mounted) return;
      mostrarMensaje(context, 'Producto eliminado correctamente');
      context.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _eliminando = false);
      mostrarMensaje(context, e.mensaje, esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: FutureBuilder<Producto>(
        future: _producto,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCargando();
          }
          if (snapshot.hasError) {
            return EstadoError(mensaje: snapshot.error.toString(), alReintentar: _recargar);
          }

          final producto = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Chip(label: Text(producto.categoria), avatar: const Icon(Icons.sell_outlined, size: 18)),
                      const Divider(height: 28),
                      _Dato(etiqueta: 'ID', valor: '${producto.id}'),
                      _Dato(etiqueta: 'Código', valor: producto.codigo),
                      _Dato(etiqueta: 'Precio unitario', valor: formatearMoneda(producto.precio)),
                      _Dato(etiqueta: 'Cantidad disponible', valor: '${producto.cantidad} unidades'),
                      _Dato(etiqueta: 'Valor en inventario', valor: formatearMoneda(producto.valorEnInventario)),
                      _Dato(
                        etiqueta: 'Descripción',
                        valor: (producto.descripcion ?? '').isEmpty ? 'Sin descripción' : producto.descripcion!,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _eliminando ? null : _editar,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _eliminando ? null : () => _eliminar(producto),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Colors.red.shade700,
                ),
                icon: _eliminando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Dato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(etiqueta, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
