require('dotenv').config();

const app = require('./app');
const { inicializarBaseDatos } = require('./config/database');

if (!process.env.JWT_SECRET) {
  console.error('Falta JWT_SECRET. Copia backend/.env.example como backend/.env y define el secreto.');
  process.exit(1);
}

const PORT = process.env.PORT || 3000;

inicializarBaseDatos();

app.listen(PORT, '0.0.0.0', () => {
  console.log(`API de inventario escuchando en http://localhost:${PORT}/api/productos`);
});
