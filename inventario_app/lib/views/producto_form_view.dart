import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/api_exception.dart';
import '../services/producto_service.dart';
import '../widgets/estados.dart';
import '../widgets/mensajes.dart';

class ProductoFormView extends StatefulWidget {
  final int? productoId;

  const ProductoFormView({super.key, this.productoId});

  bool get esEdicion => productoId != null;

  @override
  State<ProductoFormView> createState() => _ProductoFormViewState();
}

class _ProductoFormViewState extends State<ProductoFormView> {
  final ProductoService _servicio = ProductoService();
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  bool _cargando = false;
  bool _guardando = false;
  String? _errorCarga;
  Map<String, String> _erroresServidor = {};

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion) _precargarProducto();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _cantidadCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _precargarProducto() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final producto = await _servicio.obtenerProducto(widget.productoId!);
      _nombreCtrl.text = producto.nombre;
      _codigoCtrl.text = producto.codigo;
      _descripcionCtrl.text = producto.descripcion ?? '';
      _precioCtrl.text = producto.precio % 1 == 0 ? producto.precio.toInt().toString() : producto.precio.toString();
      _cantidadCtrl.text = producto.cantidad.toString();
      _categoriaCtrl.text = producto.categoria;
    } on ApiException catch (e) {
      _errorCarga = e.mensaje;
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Producto _construirProducto() {
    return Producto(
      nombre: _nombreCtrl.text.trim(),
      codigo: _codigoCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim().replaceAll(',', '.')),
      cantidad: int.parse(_cantidadCtrl.text.trim()),
      categoria: _categoriaCtrl.text.trim(),
    );
  }

  Future<void> _guardar() async {
    setState(() => _erroresServidor = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final producto = _construirProducto();
      if (widget.esEdicion) {
        await _servicio.actualizarProducto(widget.productoId!, producto);
      } else {
        await _servicio.crearProducto(producto);
      }
      if (!mounted) return;
      mostrarMensaje(context, widget.esEdicion ? 'Producto actualizado correctamente' : 'Producto registrado correctamente');
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/productos');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _erroresServidor = e.errores;
      });
      _formKey.currentState!.validate();
      mostrarMensaje(context, e.detalle, esError: true);
    }
  }

  String? _requerido(String? valor, String campo, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) return 'El $nombreCampo es obligatorio';
    return _erroresServidor[campo];
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'El precio es obligatorio';
    final precio = double.tryParse(valor.trim().replaceAll(',', '.'));
    if (precio == null || precio <= 0) return 'Ingresa un precio mayor que 0';
    return _erroresServidor['precio'];
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'La cantidad es obligatoria';
    final cantidad = int.tryParse(valor.trim());
    if (cantidad == null || cantidad < 0) return 'Ingresa un número entero mayor o igual a 0';
    return _erroresServidor['cantidad'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.esEdicion ? 'Editar producto' : 'Registrar producto')),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) return const EstadoCargando(mensaje: 'Cargando datos del producto...');
    if (_errorCarga != null) return EstadoError(mensaje: _errorCarga!, alReintentar: _precargarProducto);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre *', prefixIcon: Icon(Icons.label_outline)),
            textCapitalization: TextCapitalization.sentences,
            validator: (v) => _requerido(v, 'nombre', 'nombre'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _codigoCtrl,
            decoration: const InputDecoration(labelText: 'Código *', hintText: 'Ej: ABR-004', prefixIcon: Icon(Icons.qr_code)),
            textCapitalization: TextCapitalization.characters,
            validator: (v) => _requerido(v, 'codigo', 'código'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _categoriaCtrl,
            decoration: const InputDecoration(labelText: 'Categoría *', prefixIcon: Icon(Icons.category_outlined)),
            textCapitalization: TextCapitalization.sentences,
            validator: (v) => v == null || v.trim().isEmpty ? 'La categoría es obligatoria' : _erroresServidor['categoria'],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio *', prefixText: '\$ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  validator: _validarPrecio,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cantidadCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad *', suffixText: 'und'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validarCantidad,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descripcionCtrl,
            decoration: const InputDecoration(labelText: 'Descripción (opcional)', alignLabelWithHint: true),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save),
            label: Text(widget.esEdicion ? 'Guardar cambios' : 'Registrar producto'),
          ),
        ],
      ),
    );
  }
}
