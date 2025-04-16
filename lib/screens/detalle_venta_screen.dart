import 'package:flutter/material.dart';
import 'package:practica_tres/db/categorias_database.dart';
import 'package:practica_tres/db/detalle_venta_servicio_database.dart';
import 'package:practica_tres/db/productos_servicios_database.dart';
import 'package:practica_tres/models/categoria.dart';
import 'package:practica_tres/models/detalle_venta_servicio.dart';
import 'package:practica_tres/models/producto_servicio.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class DetalleVentaScreen extends StatefulWidget {
  final VentaServicio venta;

  const DetalleVentaScreen({super.key, required this.venta});

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  final repo = DetalleVentaServicioDatabase();
  final productosRepo = ProductosServiciosDatabase();
  final categoriasRepo = CategoriasDatabase();

  DetalleVentaServicio? detalleEditando;
  String tipoDescuento = 'Monto fijo';
  final List<String> tiposDescuento = ['Monto fijo', 'Porcentaje'];

  List<DetalleVentaServicio> detalles = [];
  List<ProductoServicio> productos = [];
  List<Categoria> categorias = [];
  List<ProductoServicio> productosFiltrados = [];

  int? categoriaSeleccionadaId;
  ProductoServicio? productoSeleccionado;
  final cantidadController = TextEditingController();
  final precioController = TextEditingController();
  final descuentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarTodo();
    descuentoController.text = '0';
  }

  Future<void> cargarTodo() async {
    final d = await repo.getByVentaId(widget.venta.id!);
    final p = await productosRepo.getAll();
    final c = await categoriasRepo.getAll();
    setState(() {
      detalles = d;
      productos = p;
      categorias = c;
      categoriaSeleccionadaId = null;
      productoSeleccionado = null;
      productosFiltrados = [];
    });
  }

  Future<void> actualizarDetalle() async {
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 1;
    final descuentoInput =
        double.tryParse(descuentoController.text.trim()) ?? 0;

    if (productoSeleccionado == null) return;

    final precioUnitario = productoSeleccionado!.precio;
    double descuentoAplicado = 0;

    if (tipoDescuento == 'Monto fijo') {
      descuentoAplicado = descuentoInput;
    } else if (tipoDescuento == 'Porcentaje') {
      descuentoAplicado = (precioUnitario * descuentoInput / 100);
    }
    final precioConDescuento = (precioUnitario - descuentoAplicado) * cantidad;
    final detalleActualizado = DetalleVentaServicio(
      id: detalleEditando!.id,
      ventaServicioId: widget.venta.id!,
      productoServicioId: productoSeleccionado!.id!,
      cantidad: cantidad,
      descuento: descuentoAplicado,
      subtotal: precioConDescuento,
    );

    await repo.update(detalleActualizado.toMap());
    detalleEditando = null;
    cantidadController.clear();
    descuentoController.text = '0';
    cargarTodo();
  }

  void filtrarProductosPorCategoria(int? categoriaId) {
    setState(() {
      categoriaSeleccionadaId = categoriaId;
      productosFiltrados =
          productos.where((p) => p.categoriaId == categoriaId).toList();
      productoSeleccionado =
          productosFiltrados.isNotEmpty ? productosFiltrados.first : null;
      if (productoSeleccionado != null) {
        precioController.text = productoSeleccionado!.precio.toStringAsFixed(2);
      }
    });
  }

  Future<void> agregarDetalle() async {
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 1;
    final descuentoInput =
        double.tryParse(descuentoController.text.trim()) ?? 0;

    if (productoSeleccionado == null) return;
    final precioUnitario = productoSeleccionado!.precio;
    double descuentoAplicado = 0;
    if (tipoDescuento == 'Monto fijo') {
      descuentoAplicado = descuentoInput;
    } else if (tipoDescuento == 'Porcentaje') {
      descuentoAplicado = (precioUnitario * descuentoInput / 100);
    }
    final precioConDescuento = (precioUnitario - descuentoAplicado) * cantidad;

    final detalle = DetalleVentaServicio(
      ventaServicioId: widget.venta.id!,
      productoServicioId: productoSeleccionado!.id!,
      cantidad: cantidad,
      descuento: descuentoAplicado,
      subtotal: precioConDescuento,
    );

    await repo.insert(detalle.toMap());
    cantidadController.clear();
    precioController.clear();
    cargarTodo();
  }

  Future<void> eliminarDetalle(int id) async {
    await repo.delete(id);
    cargarTodo();
  }

  double totalVenta() {
    return detalles.fold(0, (sum, d) => sum + d.subtotal);
  }

  String nombreProducto(int id) {
    return productos.firstWhere((p) => p.id == id).nombre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de venta')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CARD de info de la venta
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.venta.titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(widget.venta.descripcion),
                    SizedBox(height: 8),
                    Text('Cliente: ${widget.venta.nombreCliente}'),
                    Text('Cliente: ${widget.venta.fecha}'),

                    Text('Estatus: ${widget.venta.estatus}'),
                  ],
                ),
              ),
            ),

            // Formulario para agregar productos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: categoriaSeleccionadaId,
                    items:
                        categorias.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.nombre),
                          );
                        }).toList(),
                    decoration: InputDecoration(labelText: 'Categoría'),
                    onChanged: filtrarProductosPorCategoria,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<ProductoServicio>(
                    value: productoSeleccionado,
                    items:
                        productosFiltrados.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.nombre),
                          );
                        }).toList(),
                    decoration: InputDecoration(labelText: 'Producto'),
                    onChanged: (val) {
                      setState(() {
                        productoSeleccionado = val!;
                        precioController.text = val.precio.toStringAsFixed(2);
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: cantidadController,
                    decoration: InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: precioController,
                    decoration: InputDecoration(labelText: 'Precio unitario'),
                    keyboardType: TextInputType.number,
                    enabled: false,
                  ),
                  DropdownButtonFormField<String>(
                    value: tipoDescuento,
                    decoration: InputDecoration(labelText: 'Tipo de descuento'),
                    items:
                        tiposDescuento.map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        tipoDescuento = val!;
                      });
                    },
                  ),
                  TextField(
                    controller: descuentoController,
                    decoration: InputDecoration(
                      labelText: 'Descuento por unidad',
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (detalleEditando == null) {
                        agregarDetalle();
                      } else {
                        actualizarDetalle();
                      }
                    },
                    child: Text(
                      detalleEditando == null
                          ? 'Agregar al detalle'
                          : 'Actualizar detalle',
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 32),

            // Lista de detalles ya agregados
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: detalles.length,
              itemBuilder: (context, i) {
                final d = detalles[i];
                return ListTile(
                  title: Text(nombreProducto(d.productoServicioId)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precio unitario: \$${productos.firstWhere((p) => p.id == d.productoServicioId).precio.toStringAsFixed(2)}',
                      ),
                      Text('Cantidad: ${(d.cantidad)}'),
                      Text(
                        'SubTotal: \$${(productos.firstWhere((p) => p.id == d.productoServicioId).precio * d.cantidad).toStringAsFixed(2)}',
                      ),
                      Text(
                        'Descuento: \$${(d.descuento * d.cantidad).toStringAsFixed(2)}',
                      ),
                      Text('Total: \$${d.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final producto = productos.firstWhere(
                        (p) => p.id == d.productoServicioId,
                      );
                      setState(() {
                        detalleEditando = d;
                        productoSeleccionado = producto;
                        categoriaSeleccionadaId = producto.categoriaId;
                        productosFiltrados =
                            productos
                                .where(
                                  (p) => p.categoriaId == producto.categoriaId,
                                )
                                .toList();

                        cantidadController.text = d.cantidad.toString();
                        precioController.text = producto.precio.toStringAsFixed(
                          2,
                        );
                        descuentoController.text = d.descuento.toStringAsFixed(
                          2,
                        );
                      });
                    },
                  ),
                );
              },
            ),
            Divider(height: 32),
            // Total
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: \$${totalVenta().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
