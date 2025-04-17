import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:practica_tres/db/categorias_database.dart';
import 'package:practica_tres/db/detalle_venta_servicio_database.dart';
import 'package:practica_tres/db/productos_servicios_database.dart';
import 'package:practica_tres/models/categoria.dart';
import 'package:practica_tres/models/detalle_venta_servicio.dart';
import 'package:practica_tres/models/producto_servicio.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/views/confirmar_salida.dart';

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
  final List<int> idsTemporales = [];

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

  @override
  void dispose() {
    if (idsTemporales.isNotEmpty) {
      for (var id in idsTemporales) {
        repo.delete(id);
      }
    }
    super.dispose();
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

    final id = await repo.insert(detalle.toMap());
    idsTemporales.add(id);

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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final salir = await confirmarSalida(context, idsTemporales);
        if (salir) {
          Navigator.of(context).pop();
        }
      },

      child: Scaffold(
        //backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Detalle de venta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: Text(
                detalles.length.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: IconButton(
                icon: Icon(Icons.inventory_2),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Bienes Agregados'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: detalles.length,
                              itemBuilder: (context, index) {
                                final d = detalles[index];
                                final producto = productos.firstWhere(
                                  (p) => p.id == d.productoServicioId,
                                );
                                return ListTile(
                                  title: Text(producto.nombre),
                                  subtitle: Text('Cantidad: ${d.cantidad}'),
                                  trailing: Text(
                                    '\$${d.subtotal.toStringAsFixed(2)}',
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cerrar'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Información de la venta
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 8,
                color: Colors.white,
                shadowColor: Colors.deepPurpleAccent[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.venta.titulo,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        widget.venta.descripcion,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Divider(height: 24, thickness: 1.2),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Cliente: ${widget.venta.nombreCliente}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Fecha: ${widget.venta.fecha}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Estatus: ${widget.venta.estatus}',
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  widget.venta.estatus == "Completado"
                                      ? Colors.green
                                      : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 32),

              // Formulario para agregar/editar productos
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Agregar producto o servicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: categoriaSeleccionadaId,
                      items:
                          categorias.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.nombre),
                            );
                          }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      onChanged: filtrarProductosPorCategoria,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<ProductoServicio>(
                      value: productoSeleccionado,
                      items:
                          productosFiltrados.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.nombre),
                            );
                          }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Producto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
                      onChanged: (val) {
                        setState(() {
                          productoSeleccionado = val!;
                          precioController.text = val.precio.toStringAsFixed(2);
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: cantidadController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: precioController,
                      decoration: InputDecoration(
                        labelText: 'Precio unitario',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: false,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tipoDescuento,
                      decoration: InputDecoration(
                        labelText: 'Tipo de descuento por unidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.percent),
                      ),
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
                    SizedBox(height: 12),
                    TextField(
                      controller: descuentoController,
                      decoration: InputDecoration(
                        labelText: 'Descuento por unidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.local_offer_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          detalleEditando == null ? Icons.add : Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          detalleEditando == null
                              ? 'Agregar al detalle'
                              : 'Actualizar detalle',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (detalleEditando == null) {
                            agregarDetalle();
                          } else {
                            actualizarDetalle();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    if (detalleEditando != null)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              detalleEditando = null;
                              cantidadController.clear();
                              descuentoController.text = '0';
                              precioController.clear();
                              productoSeleccionado = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          label: Text(
                            'Cancelar edición',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
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
                  final producto = productos.firstWhere(
                    (p) => p.id == d.productoServicioId,
                  );
                  final subtotal = (producto.precio * d.cantidad);
                  final descuentoTotal = d.descuento * d.cantidad;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.deepPurpleAccent[400],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del producto y botones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  nombreProducto(d.productoServicioId),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        detalleEditando = d;
                                        productoSeleccionado = producto;
                                        categoriaSeleccionadaId =
                                            producto.categoriaId;
                                        productosFiltrados =
                                            productos
                                                .where(
                                                  (p) =>
                                                      p.categoriaId ==
                                                      producto.categoriaId,
                                                )
                                                .toList();
                                        cantidadController.text =
                                            d.cantidad.toString();
                                        precioController.text = producto.precio
                                            .toStringAsFixed(2);
                                        descuentoController.text = d.descuento
                                            .toStringAsFixed(2);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => eliminarDetalle(d.id!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(height: 1, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          // Info de precios
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Precio unitario: \$${producto.precio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.format_list_numbered,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Cantidad: ${d.cantidad}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.remove_circle_outline,
                                size: 18,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Descuento total: \$${descuentoTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calculate_outlined,
                                size: 18,
                                color: Colors.green,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Total: \$${d.subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Divider(height: 32),

              // Total de la venta
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: \$${totalVenta().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ),
              Divider(height: 32),

              // Botón para terminar el registro
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        idsTemporales.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registro finalizado')),
                      );
                    },

                    icon: Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      'Guardar registro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
