import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000/api';
}
