import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/models/resumen_inventario.dart';

void main() {
  test('El resumen calcula unidades y valor total del inventario', () {
    const productos = [
      Producto(nombre: 'A', codigo: 'A-1', precio: 1000, cantidad: 2, categoria: 'X'),
      Producto(nombre: 'B', codigo: 'B-1', precio: 500, cantidad: 4, categoria: 'X'),
    ];

    final resumen = ResumenInventario.desdeProductos(productos);

    expect(resumen.totalProductos, 2);
    expect(resumen.totalUnidades, 6);
    expect(resumen.valorTotal, 4000);
  });
}
