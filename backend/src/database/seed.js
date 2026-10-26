const { db, crearTabla, insertarSemilla } = require('../config/database');

crearTabla();
db.exec('DELETE FROM productos');
db.exec("DELETE FROM sqlite_sequence WHERE name = 'productos'");
insertarSemilla();

const { total } = db.prepare('SELECT COUNT(*) AS total FROM productos').get();
console.log(`Base de datos reiniciada con ${total} productos de prueba`);
