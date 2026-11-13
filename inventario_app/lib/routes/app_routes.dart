class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String sesion = '/sesion';

  static const String dashboard = '/';
  static const String productos = '/productos';
  static const String nuevoProducto = '/productos/nuevo';

  static String detalleProducto(int id) => '/productos/$id';
  static String editarProducto(int id) => '/productos/$id/editar';
}
