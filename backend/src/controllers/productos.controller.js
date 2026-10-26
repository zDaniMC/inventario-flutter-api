const { db } = require('../config/database');
const { validarProducto } = require('../validators/producto.validator');

const CAMPOS = 'id, nombre, codigo, descripcion, precio, cantidad, categoria, created_at, updated_at';

function buscarPorId(id) {
  return db.prepare(`SELECT ${CAMPOS} FROM productos WHERE id = ?`).get(id);
}

function codigoEnUso(codigo, idExcluido = 0) {
  return db.prepare('SELECT id FROM productos WHERE codigo = ? AND id != ?').get(codigo, idExcluido);
}

function leerId(req) {
  const id = Number(req.params.id);
  return Number.isInteger(id) && id > 0 ? id : null;
}

function listar(req, res) {
  const productos = db.prepare(`SELECT ${CAMPOS} FROM productos ORDER BY id DESC`).all();
  res.status(200).json({ mensaje: 'Productos obtenidos correctamente', total: productos.length, data: productos });
}

function obtenerPorId(req, res) {
  const id = leerId(req);
  const producto = id ? buscarPorId(id) : null;
  if (!producto) {
    return res.status(404).json({ mensaje: `No existe un producto con id ${req.params.id}` });
  }
  res.status(200).json({ mensaje: 'Producto encontrado', data: producto });
}

function crear(req, res) {
  const resultado = validarProducto(req.body || {});
  if (!resultado.valido) {
    return res.status(422).json({ mensaje: 'Datos inválidos', errores: resultado.errores });
  }

  const { producto } = resultado;
  if (codigoEnUso(producto.codigo)) {
    return res.status(409).json({
      mensaje: 'Ya existe un producto con ese código',
      errores: { codigo: `El código ${producto.codigo} ya está registrado` },
    });
  }

  const info = db.prepare(`
    INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
    VALUES (@nombre, @codigo, @descripcion, @precio, @cantidad, @categoria)
  `).run(producto);

  res.status(201).json({ mensaje: 'Producto registrado correctamente', data: buscarPorId(info.lastInsertRowid) });
}

function actualizar(req, res) {
  const id = leerId(req);
  if (!id || !buscarPorId(id)) {
    return res.status(404).json({ mensaje: `No existe un producto con id ${req.params.id}` });
  }

  const resultado = validarProducto(req.body || {});
  if (!resultado.valido) {
    return res.status(422).json({ mensaje: 'Datos inválidos', errores: resultado.errores });
  }

  const { producto } = resultado;
  if (codigoEnUso(producto.codigo, id)) {
    return res.status(409).json({
      mensaje: 'Ya existe otro producto con ese código',
      errores: { codigo: `El código ${producto.codigo} ya está registrado` },
    });
  }

  db.prepare(`
    UPDATE productos
    SET nombre = @nombre, codigo = @codigo, descripcion = @descripcion,
        precio = @precio, cantidad = @cantidad, categoria = @categoria,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = @id
  `).run({ ...producto, id });

  res.status(200).json({ mensaje: 'Producto actualizado correctamente', data: buscarPorId(id) });
}

function eliminar(req, res) {
  const id = leerId(req);
  const producto = id ? buscarPorId(id) : null;
  if (!producto) {
    return res.status(404).json({ mensaje: `No existe un producto con id ${req.params.id}` });
  }

  db.prepare('DELETE FROM productos WHERE id = ?').run(id);
  res.status(200).json({ mensaje: 'Producto eliminado correctamente', data: producto });
}

module.exports = { listar, obtenerPorId, crear, actualizar, eliminar };
