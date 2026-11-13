import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import 'sesion_storage.dart';

enum EstadoSesion { verificando, autenticado, sinSesion }

/// Estado global de la sesión. El router lo escucha (refreshListenable) y
/// redirige solo: sin sesión -> login; con sesión -> dashboard.
class SesionController extends ChangeNotifier {
  SesionController._();

  static final SesionController instance = SesionController._();

  final AuthService _auth = AuthService();

  EstadoSesion _estado = EstadoSesion.verificando;
  Usuario? _usuario;
  String? _aviso;

  EstadoSesion get estado => _estado;
  Usuario? get usuario => _usuario;
  bool get autenticado => _estado == EstadoSesion.autenticado;

  /// Mensaje para el login (por ejemplo, "tu sesión expiró"). Se consume una vez.
  String? consumirAviso() {
    final aviso = _aviso;
    _aviso = null;
    return aviso;
  }

  void _cambiar(EstadoSesion estado) {
    _estado = estado;
    notifyListeners();
  }

  /// Al abrir la app: si hay token guardado, se valida contra el backend.
  Future<void> restaurar() async {
    final token = await SesionStorage.leerToken();
    if (token == null) {
      _cambiar(EstadoSesion.sinSesion);
      return;
    }
    try {
      final usuario = await _auth.perfil();
      await SesionStorage.guardarUsuario(usuario);
      _usuario = usuario;
      _cambiar(EstadoSesion.autenticado);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await sesionExpirada();
      } else {
        // Sin conexión con el servidor: se conserva la sesión con los datos locales.
        final local = await SesionStorage.leerUsuario();
        if (local != null) {
          _usuario = local;
          _cambiar(EstadoSesion.autenticado);
        } else {
          _cambiar(EstadoSesion.sinSesion);
        }
      }
    }
  }

  /// Lanza ApiException si las credenciales son incorrectas o no hay conexión.
  Future<void> login(String email, String password) async {
    final usuario = await _auth.login(email.trim(), password);
    _usuario = usuario;
    _aviso = null;
    _cambiar(EstadoSesion.autenticado);
  }

  /// Cierre de sesión: borra token y datos locales; el router lleva al login.
  Future<void> logout() async {
    _estado = EstadoSesion.sinSesion;
    _usuario = null;
    _aviso = null;
    await SesionStorage.limpiar();
    notifyListeners();
  }

  /// La API respondió 401 (token ausente, inválido o expirado).
  Future<void> sesionExpirada() async {
    if (_estado == EstadoSesion.sinSesion) return;
    _estado = EstadoSesion.sinSesion;
    _usuario = null;
    _aviso = 'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';
    await SesionStorage.limpiar();
    notifyListeners();
  }
}
