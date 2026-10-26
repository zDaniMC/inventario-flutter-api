import 'package:flutter/material.dart';

import '../config/formatters.dart';
import '../models/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback alPresionar;

  const ProductoCard({super.key, required this.producto, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final sinStock = producto.cantidad == 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        onTap: alPresionar,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: colores.primaryContainer,
          child: Text(
            producto.nombre.isNotEmpty ? producto.nombre[0].toUpperCase() : '?',
            style: TextStyle(color: colores.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(formatearMoneda(producto.precio)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${producto.cantidad}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: sinStock ? Colors.red.shade700 : colores.primary,
              ),
            ),
            Text(sinStock ? 'agotado' : 'unidades', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
