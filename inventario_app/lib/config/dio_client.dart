import 'package:dio/dio.dart';

import '../services/sesion_controller.dart';
import '../services/sesion_storage.dart';
import 'env_config.dart';

class DioClient {
  DioClient._();

  static final Dio instance = _crear();

  static Dio _crear() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // Agrega  Authorization: Bearer <token>  a cada petición.
        onRequest: (options, handler) async {
          final token = await SesionStorage.leerToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        // Si la API rechaza el token (401) en un servicio protegido, se cierra la sesión.
        onError: (error, handler) {
          final esLogin = error.requestOptions.path.contains('/auth/login');
          if (error.response?.statusCode == 401 && !esLogin) {
            SesionController.instance.sesionExpirada();
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
