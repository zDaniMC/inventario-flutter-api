# InvenTrack — Sistema de Gestión de Inventario

Solución para administrar el inventario de productos de un establecimiento comercial. Está compuesta por:

- **`backend/`** — API REST en Node.js + Express con base de datos SQLite (persistencia real en archivo).
- **`inventario_app/`** — Aplicación móvil Flutter que consume la API con Dio, navega con go_router y lee la URL base desde un archivo `.env` (flutter_dotenv).

Segundo Parcial Práctico — Electiva Profesional I: Desarrollo de Aplicaciones Móviles.

---

## Tecnologías

| Capa | Tecnología |
|------|------------|
| Backend | Node.js 18+, Express 4, better-sqlite3, CORS |
| Base de datos | SQLite (archivo `backend/data/inventario.db`) |
| Frontend | Flutter 3.27+ / Dart 3.6+ |
| HTTP | Dio 5 |
| Navegación | go_router 14 |
| Configuración | flutter_dotenv 5 |

---

## Estructura del repositorio

```
.
├── backend/
│   ├── package.json
│   └── src/
│       ├── server.js
│       ├── app.js
│       ├── config/database.js
│       ├── controllers/productos.controller.js
│       ├── routes/productos.routes.js
│       ├── validators/producto.validator.js
│       └── database/
│           ├── productos.seed.json
│           └── seed.js
└── inventario_app/
    ├── .env.example
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── config/      (env_config, dio_client, formatters)
        ├── models/      (producto, resumen_inventario)
        ├── routes/      (app_router, app_routes)
        ├── services/    (producto_service, api_exception)
        ├── themes/      (app_theme)
        ├── views/       (dashboard, productos, detalle, formulario)
        └── widgets/     (app_drawer, stat_card, producto_card, estados, mensajes)
```

---

## Instalación y ejecución

### 1. Backend

Requisitos: Node.js 18 o superior.

```bash
cd backend
npm install
npm start
```

La API queda en `http://localhost:3000/api/productos`. La primera vez se crea la base de datos `backend/data/inventario.db` con **10 productos de prueba**.

Para reiniciar la base de datos a los 10 productos originales:

```bash
npm run seed
```

### 2. Aplicación Flutter

Requisitos: Flutter 3.27 o superior.

```bash
cd inventario_app
flutter create . --project-name inventario_app --platforms=android
cp .env.example .env
flutter pub get
flutter run   (o el botón Run de Android Studio con el emulador Pixel 8)
```

Contenido de `.env` según dónde se ejecute la app:

| Dispositivo | API_URL |
|-------------|---------|
| Emulador Android | `http://10.0.2.2:3000/api` |
| Chrome / Windows | `http://localhost:3000/api` |
| Celular físico (misma red Wi-Fi) | `http://IP_DEL_PC:3000/api` |
| API desplegada | `https://tu-api.up.railway.app/api` |

El archivo `android/app/src/main/AndroidManifest.xml` ya incluye `android:usesCleartextTraffic="true"` y el permiso INTERNET para permitir HTTP local en Android.

---

## Base de datos

Tabla `productos`:

| Campo | Tipo | Restricción |
|-------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| nombre | TEXT | NOT NULL |
| codigo | TEXT | NOT NULL, UNIQUE |
| descripcion | TEXT | Opcional |
| precio | REAL | NOT NULL, > 0 |
| cantidad | INTEGER | NOT NULL, >= 0 |
| categoria | TEXT | NOT NULL |
| created_at | TEXT | Fecha de creación |
| updated_at | TEXT | Fecha de última modificación |

---

## Endpoints

| Método | Endpoint | Descripción | Códigos |
|--------|----------|-------------|---------|
| GET | `/api/productos` | Lista todos los productos | 200 |
| GET | `/api/productos/{id}` | Detalle de un producto | 200, 404 |
| POST | `/api/productos` | Registra un producto | 201, 409, 422 |
| PUT | `/api/productos/{id}` | Actualiza un producto | 200, 404, 409, 422 |
| DELETE | `/api/productos/{id}` | Elimina un producto | 200, 404 |

Validaciones: `nombre`, `codigo` y `categoria` obligatorios; `precio` numérico mayor que 0; `cantidad` entero mayor o igual a 0; `codigo` único (se guarda en mayúsculas).

---

## Ejemplos de peticiones y respuestas

### GET /api/productos — 200

```json
{
  "mensaje": "Productos obtenidos correctamente",
  "total": 10,
  "data": [
    {
      "id": 1,
      "nombre": "Arroz Diana 500 g",
      "codigo": "ABR-001",
      "descripcion": "Arroz blanco de grano largo",
      "precio": 2800,
      "cantidad": 120,
      "categoria": "Abarrotes",
      "created_at": "2026-10-26 16:37:15",
      "updated_at": "2026-10-26 16:37:15"
    }
  ]
}
```

### GET /api/productos/3 — 200

```json
{
  "mensaje": "Producto encontrado",
  "data": {
    "id": 3,
    "nombre": "Azúcar Manuelita 1 kg",
    "codigo": "ABR-003",
    "descripcion": "Azúcar blanca refinada",
    "precio": 4900,
    "cantidad": 80,
    "categoria": "Abarrotes",
    "created_at": "2026-10-26 16:37:15",
    "updated_at": "2026-10-26 16:37:15"
  }
}
```

### GET /api/productos/999 — 404

```json
{ "mensaje": "No existe un producto con id 999" }
```

### POST /api/productos — 201

Petición:

```json
{
  "nombre": "Café Sello Rojo 250 g",
  "codigo": "BEB-003",
  "descripcion": "Café molido tradicional",
  "precio": 9800,
  "cantidad": 20,
  "categoria": "Bebidas"
}
```

Respuesta:

```json
{
  "mensaje": "Producto registrado correctamente",
  "data": {
    "id": 11,
    "nombre": "Café Sello Rojo 250 g",
    "codigo": "BEB-003",
    "descripcion": "Café molido tradicional",
    "precio": 9800,
    "cantidad": 20,
    "categoria": "Bebidas",
    "created_at": "2026-10-26 16:40:02",
    "updated_at": "2026-10-26 16:40:02"
  }
}
```

### POST /api/productos — 422 (datos inválidos)

```json
{
  "mensaje": "Datos inválidos",
  "errores": {
    "nombre": "El nombre es obligatorio",
    "precio": "El precio debe ser un número mayor que 0",
    "cantidad": "La cantidad debe ser un número entero mayor o igual a 0"
  }
}
```

### POST /api/productos — 409 (código repetido)

```json
{
  "mensaje": "Ya existe un producto con ese código",
  "errores": { "codigo": "El código BEB-003 ya está registrado" }
}
```

### PUT /api/productos/11 — 200

Petición:

```json
{
  "nombre": "Café Sello Rojo 500 g",
  "codigo": "BEB-003",
  "descripcion": "Café molido tradicional",
  "precio": 17500,
  "cantidad": 15,
  "categoria": "Bebidas"
}
```

Respuesta:

```json
{
  "mensaje": "Producto actualizado correctamente",
  "data": {
    "id": 11,
    "nombre": "Café Sello Rojo 500 g",
    "codigo": "BEB-003",
    "descripcion": "Café molido tradicional",
    "precio": 17500,
    "cantidad": 15,
    "categoria": "Bebidas",
    "created_at": "2026-10-26 16:40:02",
    "updated_at": "2026-10-26 16:45:10"
  }
}
```

### DELETE /api/productos/11 — 200

```json
{
  "mensaje": "Producto eliminado correctamente",
  "data": { "id": 11, "nombre": "Café Sello Rojo 500 g", "codigo": "BEB-003" }
}
```

---

## Funcionalidades de la app

- **Dashboard**: nombre e ícono de la app, menú lateral, tarjetas con total de productos, total de unidades y valor total del inventario (Σ precio × cantidad), calculados con datos reales de la API.
- **Listado**: nombre, precio y cantidad de cada producto, con recarga deslizando hacia abajo.
- **Detalle**: todos los campos del producto y su valor en inventario.
- **Registro y edición**: formulario con validaciones; en edición los datos se precargan desde la API.
- **Eliminación**: con diálogo de confirmación.
- Estados de carga, error (con botón Reintentar) y lista vacía; mensajes de éxito y error con SnackBar.

---

## URL pública de la API

_Local:_ `http://localhost:3000/api/productos`

_Desplegada (si aplica):_ `https://________________/api/productos`

---

## Autor

Nombre: ______________________ — Código: __________
