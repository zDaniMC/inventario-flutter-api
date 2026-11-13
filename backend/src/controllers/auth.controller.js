const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { db } = require('../config/database');

// Hash de relleno para que el tiempo de respuesta no revele si el correo existe.
const HASH_RELLENO = bcrypt.hashSync('relleno-no-valido', 10);

function datosPublicos(usuario) {
  return { id: usuario.id, nombre: usuario.nombre, email: usuario.email };
}

function login(req, res) {
  const { email, password } = req.body || {};

  const errores = {};
  if (typeof email !== 'string' || !email.trim()) errores.email = 'El correo es obligatorio';
  if (typeof password !== 'string' || !password) errores.password = 'La contraseña es obligatoria';
  if (Object.keys(errores).length > 0) {
    return res.status(422).json({ mensaje: 'Datos inválidos', errores });
  }

  const usuario = db
    .prepare('SELECT id, nombre, email, password_hash FROM usuarios WHERE email = ?')
    .get(email.trim().toLowerCase());

  const coincide = bcrypt.compareSync(password, usuario ? usuario.password_hash : HASH_RELLENO);
  if (!usuario || !coincide) {
    return res.status(401).json({ mensaje: 'Credenciales incorrectas' });
  }

  const token = jwt.sign({ email: usuario.email }, process.env.JWT_SECRET, {
    subject: String(usuario.id),
    expiresIn: process.env.JWT_EXPIRES_IN || '1h',
  });

  res.status(200).json({
    mensaje: 'Inicio de sesión exitoso',
    token,
    usuario: datosPublicos(usuario),
  });
}

// GET /api/auth/me (protegida): permite a la app comprobar que su sesión sigue vigente.
function perfil(req, res) {
  const usuario = db
    .prepare('SELECT id, nombre, email FROM usuarios WHERE id = ?')
    .get(req.usuario.id);
  if (!usuario) {
    return res.status(401).json({ mensaje: 'Token inválido' });
  }
  res.status(200).json({ mensaje: 'Sesión válida', usuario: datosPublicos(usuario) });
}

module.exports = { login, perfil };
