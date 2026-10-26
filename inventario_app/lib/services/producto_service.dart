import 'package:dio/dio.dart';

import '../config/dio_client.dart';
import '../models/producto.dart';
import '../models/resumen_inventario.dart';
import 'api_exception.dart';

class ProductoService {
  final Dio _dio;

  ProductoService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  static const String _ruta = '/productos';

  Future<List<Producto>> obtenerProductos() async {
    try {
      final respuesta = await _dio.get(_ruta);
      final lista = respuesta.data['data'] as List<dynamic>;
      return lista.map((item) => Producto.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  Future<Producto> obtenerProducto(int id) async {
    try {
      final respuesta = await _dio.get('$_ruta/$id');
      return Producto.fromJson(respuesta.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  Future<Producto> crearProducto(Producto producto) async {
    try {
      final respuesta = await _dio.post(_ruta, data: producto.toJson());
      return Producto.fromJson(respuesta.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  Future<Producto> actualizarProducto(int id, Producto producto) async {
    try {
      final respuesta = await _dio.put('$_ruta/$id', data: producto.toJson());
      return Producto.fromJson(respuesta.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      await _dio.delete('$_ruta/$id');
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  Future<ResumenInventario> obtenerResumen() async {
    final productos = await obtenerProductos();
    return ResumenInventario.desdeProductos(productos);
  }
}
