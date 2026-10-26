import 'producto.dart';

class ResumenInventario {
  final int totalProductos;
  final int totalUnidades;
  final double valorTotal;

  const ResumenInventario({
    required this.totalProductos,
    required this.totalUnidades,
    required this.valorTotal,
  });

  factory ResumenInventario.desdeProductos(List<Producto> productos) {
    return ResumenInventario(
      totalProductos: productos.length,
      totalUnidades: productos.fold(0, (suma, p) => suma + p.cantidad),
      valorTotal: productos.fold(0.0, (suma, p) => suma + p.valorEnInventario),
    );
  }
}
