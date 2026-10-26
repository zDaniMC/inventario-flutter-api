import 'package:flutter/material.dart';

class EstadoCargando extends StatelessWidget {
  final String mensaje;

  const EstadoCargando({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(mensaje),
        ],
      ),
    );
  }
}

class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback alReintentar;

  const EstadoError({super.key, required this.mensaje, required this.alReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class EstadoVacio extends StatelessWidget {
  final String mensaje;

  const EstadoVacio({super.key, this.mensaje = 'No hay productos registrados'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black38),
          const SizedBox(height: 16),
          Text(mensaje),
        ],
      ),
    );
  }
}
