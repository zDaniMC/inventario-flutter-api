const app = require('./app');
const { inicializarBaseDatos } = require('./config/database');

const PORT = process.env.PORT || 3000;

inicializarBaseDatos();

app.listen(PORT, '0.0.0.0', () => {
  console.log(`API de inventario escuchando en http://localhost:${PORT}/api/productos`);
});
