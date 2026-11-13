const path = require('path');
const fs = require('fs');
const Database = require('better-sqlite3');
const bcrypt = require('bcryptjs');
const productosSemilla = require('../database/productos.seed.json');

const rutaDb = process.env.DB_PATH || path.join(__dirname, '..', '..', 'data', 'inventario.db');
fs.mkdirSync(path.dirname(rutaDb), { recursive: true });

const db = new Database(rutaDb);
db.pragma('journal_mode = WAL');

function crearTabla() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS productos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      codigo TEXT NOT NULL UNIQUE,
      descripcion TEXT,
      precio REAL NOT NULL CHECK (precio > 0),
      cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
      categoria TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

function insertarSemilla() {
  const insertar = db.prepare(`
    INSERT OR IGNORE INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
    VALUES (@nombre, @codigo, @descripcion, @precio, @cantidad, @categoria)
  `);
  const insertarTodos = db.transaction((productos) => {
    for (const producto of productos) insertar.run(producto);
  });
  insertarTodos(productosSemilla);
}

// --- Autenticación ---------------------------------------------------------

function crearTablaUsuarios() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

// Crea un usuario de pruebas solo si no existe ninguno. La contraseña se guarda con bcrypt.
function crearUsuarioInicial() {
  const { total } = db.prepare('SELECT COUNT(*) AS total FROM usuarios').get();
  if (total > 0) return;

  const nombre = process.env.ADMIN_NOMBRE || 'Administrador';
  const email = (process.env.ADMIN_EMAIL || 'admin@inventrack.com').toLowerCase();
  const password = process.env.ADMIN_PASSWORD || 'Admin1234';

  db.prepare('INSERT INTO usuarios (nombre, email, password_hash) VALUES (?, ?, ?)')
    .run(nombre, email, bcrypt.hashSync(password, 10));
  console.log(`Usuario inicial creado: ${email}`);
}

function inicializarBaseDatos() {
  crearTabla();
  crearTablaUsuarios();
  const { total } = db.prepare('SELECT COUNT(*) AS total FROM productos').get();
  if (total === 0) {
    insertarSemilla();
    console.log(`Base de datos creada con ${productosSemilla.length} productos de prueba`);
  }
  crearUsuarioInicial();
}

module.exports = { db, inicializarBaseDatos, crearTabla, insertarSemilla };
