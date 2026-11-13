const jwt = require('jsonwebtoken');

/**
 * Protege una ruta: exige el encabezado  Authorization: Bearer <token>.
 * Responde 401 si el token falta, es inválido o está expirado.
 */
function verificarToken(req, res, next) {
  const encabezado = req.headers.authorization || '';
  const [tipo, token] = encabezado.split(' ');

  if (tipo !== 'Bearer' || !token) {
    return res.status(401).json({ mensaje: 'Token no proporcionado' });
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = { id: Number(payload.sub), email: payload.email };
    return next();
  } catch (err) {
    const mensaje = err.name === 'TokenExpiredError' ? 'Token expirado' : 'Token inválido';
    return res.status(401).json({ mensaje });
  }
}

module.exports = verificarToken;
