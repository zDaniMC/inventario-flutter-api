import 'package:dio/dio.dart';

import '../config/dio_client.dart';
import '../models/usuario.dart';
import 'api_exception.dart';
import 'sesion_storage.dart';

/// Peticiones de autenticación. Como el resto de servicios, es la única capa
/// que habla con Dio; las vistas no lo usan directamente.
class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// POST /auth/login. Si las credenciales son correctas guarda el token
  /// (almacenamiento seguro) y los datos del usuario.
  Future<Usuario> login(String email, String password) async {
    try {
      final respuesta = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final datos = respuesta.data as Map<String, dynamic>;
      final usuario = Usuario.fromJson(datos['usuario'] as Map<String, dynamic>);
      await SesionStorage.guardarToken(datos['token'] as String);
      await SesionStorage.guardarUsuario(usuario);
      return usuario;
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  /// GET /auth/me: comprueba con el backend que el token guardado siga vigente.
  Future<Usuario> perfil() async {
    try {
      final respuesta = await _dio.get('/auth/me');
      final datos = respuesta.data as Map<String, dynamic>;
      return Usuario.fromJson(datos['usuario'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }
}
