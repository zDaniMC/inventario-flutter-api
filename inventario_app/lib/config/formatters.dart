String formatearMoneda(double valor) {
  return '\$ ${formatearNumero(valor.round())}';
}

String formatearNumero(int valor) {
  final texto = valor.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    final posicionDesdeFinal = texto.length - i;
    buffer.write(texto[i]);
    if (posicionDesdeFinal > 1 && posicionDesdeFinal % 3 == 1) {
      buffer.write('.');
    }
  }
  return valor < 0 ? '-$buffer' : buffer.toString();
}
