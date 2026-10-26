const path = require('path');
const fs = require('fs');
const Database = require('better-sqlite3');
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

function inicializarBaseDatos() {
  crearTabla();
  const { total } = db.prepare('SELECT COUNT(*) AS total FROM productos').get();
  if (total === 0) {
    insertarSemilla();
    console.log(`Base de datos creada con ${productosSemilla.length} productos de prueba`);
  }
}

module.exports = { db, inicializarBaseDatos, crearTabla, insertarSemilla };
