const { Router } = require('express');
const controlador = require('../controllers/auth.controller');
const verificarToken = require('../middleware/auth.middleware');

const router = Router();

router.post('/login', controlador.login);
router.get('/me', verificarToken, controlador.perfil);

module.exports = router;
