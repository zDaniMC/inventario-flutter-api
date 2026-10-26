function esTextoValido(valor) {
  return typeof valor === 'string' && valor.trim().length > 0;
}

function validarProducto(datos) {
  const errores = {};

  if (!esTextoValido(datos.nombre)) errores.nombre = 'El nombre es obligatorio';
  if (!esTextoValido(datos.codigo)) errores.codigo = 'El código es obligatorio';
  if (!esTextoValido(datos.categoria)) errores.categoria = 'La categoría es obligatoria';

  if (datos.descripcion !== undefined && datos.descripcion !== null && typeof datos.descripcion !== 'string') {
    errores.descripcion = 'La descripción debe ser texto';
  }

  const precio = Number(datos.precio);
  if (datos.precio === undefined || datos.precio === null || datos.precio === '') {
    errores.precio = 'El precio es obligatorio';
  } else if (Number.isNaN(precio) || precio <= 0) {
    errores.precio = 'El precio debe ser un número mayor que 0';
  }

  const cantidad = Number(datos.cantidad);
  if (datos.cantidad === undefined || datos.cantidad === null || datos.cantidad === '') {
    errores.cantidad = 'La cantidad es obligatoria';
  } else if (!Number.isInteger(cantidad) || cantidad < 0) {
    errores.cantidad = 'La cantidad debe ser un número entero mayor o igual a 0';
  }

  if (Object.keys(errores).length > 0) {
    return { valido: false, errores };
  }

  return {
    valido: true,
    producto: {
      nombre: datos.nombre.trim(),
      codigo: datos.codigo.trim().toUpperCase(),
      descripcion: esTextoValido(datos.descripcion) ? datos.descripcion.trim() : null,
      precio,
      cantidad,
      categoria: datos.categoria.trim(),
    },
  };
}

module.exports = { validarProducto };
