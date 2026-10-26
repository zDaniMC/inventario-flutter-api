import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;
  final Map<String, String> errores;

  const ApiException(this.mensaje, {this.statusCode, this.errores = const {}});

  factory ApiException.desdeDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('El servidor tardó demasiado en responder. Intenta de nuevo.');
      case DioExceptionType.connectionError:
        return const ApiException('No se pudo conectar con la API. Verifica que el servidor esté encendido y la URL del archivo .env.');
      case DioExceptionType.cancel:
        return const ApiException('La petición fue cancelada.');
      case DioExceptionType.badResponse:
        return _desdeRespuesta(error.response);
      default:
        return const ApiException('Ocurrió un error inesperado de comunicación.');
    }
  }

  static ApiException _desdeRespuesta(Response<dynamic>? respuesta) {
    final codigo = respuesta?.statusCode;
    final datos = respuesta?.data;
    var mensaje = 'Error del servidor (${codigo ?? 'desconocido'}).';
    var errores = <String, String>{};

    if (datos is Map) {
      if (datos['mensaje'] is String) mensaje = datos['mensaje'] as String;
      if (datos['errores'] is Map) {
        errores = (datos['errores'] as Map).map((clave, valor) => MapEntry(clave.toString(), valor.toString()));
      }
    }

    return ApiException(mensaje, statusCode: codigo, errores: errores);
  }

  String get detalle => errores.isEmpty ? mensaje : '$mensaje: ${errores.values.join(', ')}';

  @override
  String toString() => mensaje;
}
