import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

/// Almacenamiento local de la sesión.
/// - Token JWT  -> flutter_secure_storage (cifrado).
/// - Nombre y correo (no sensibles) -> shared_preferences.
/// La contraseña nunca se guarda.
class SesionStorage {
  SesionStorage._();

  static const _claveToken = 'access_token';
  static const _claveId = 'usuario_id';
  static const _claveNombre = 'usuario_nombre';
  static const _claveEmail = 'usuario_email';

  static const FlutterSecureStorage _seguro = FlutterSecureStorage();

  static Future<void> guardarToken(String token) =>
      _seguro.write(key: _claveToken, value: token);

  static Future<String?> leerToken() => _seguro.read(key: _claveToken);

  static Future<void> guardarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_claveId, usuario.id);
    await prefs.setString(_claveNombre, usuario.nombre);
    await prefs.setString(_claveEmail, usuario.email);
  }

  static Future<Usuario?> leerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_claveId);
    final nombre = prefs.getString(_claveNombre);
    final email = prefs.getString(_claveEmail);
    if (id == null || nombre == null || email == null) return null;
    return Usuario(id: id, nombre: nombre, email: email);
  }

  /// Cierre de sesión: elimina el token y los datos del usuario.
  static Future<void> limpiar() async {
    await _seguro.delete(key: _claveToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveId);
    await prefs.remove(_claveNombre);
    await prefs.remove(_claveEmail);
  }

  /// Fecha de expiración leída del payload del JWT. Solo es informativa:
  /// la validación real del token la hace el backend.
  static DateTime? expiracion(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
      final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'];
      if (exp is! int) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      return null;
    }
  }
}
