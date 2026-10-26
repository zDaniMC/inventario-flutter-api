const { db, crearTabla } = require('../config/database');

crearTabla();

const productos = db
  .prepare('SELECT id, nombre, codigo, precio, cantidad, categoria FROM productos ORDER BY id')
  .all();

console.log(`Tabla productos — ${productos.length} registros (archivo data/inventario.db)`);
console.table(productos);
