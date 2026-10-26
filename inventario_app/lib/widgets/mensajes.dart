import 'package:flutter/material.dart';

void mostrarMensaje(BuildContext context, String texto, {bool esError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Eliminar',
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (contextoDialogo) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contextoDialogo).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700, minimumSize: const Size(96, 40)),
          onPressed: () => Navigator.of(contextoDialogo).pop(true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}
