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
import 'package:practica_tres/views/detalle_venta/detalle_card.dart';
import 'package:practica_tres/views/detalle_venta/detalle_form.dart';
import 'package:practica_tres/views/detalle_venta/detalles_dialog.dart';
import 'package:practica_tres/views/detalle_venta/venta_info_card.dart';
import 'package:practica_tres/views/form_eliminar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  Future<void> guardarDetalle({int? detalleId}) async {
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 1;
    final descuentoInput =
        double.tryParse(descuentoController.text.trim()) ?? 0;

    if (widget.venta.estatus == 'Completada' ||
        widget.venta.estatus == 'Cancelada') {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message:
              "No se puede modificar una venta que esta ${widget.venta.estatus.toLowerCase()}.",
        ),
      );
      return;
    }

    if (productoSeleccionado == null) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "Selecciona un producto."),
      );
      return;
    }
    if (cantidad <= 0) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "La cantidad debe ser mayor a 0."),
      );
      return;
    }
    if (descuentoInput < 0) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "El descuento no puede ser negativo."),
      );
      return;
    }

    final precioUnitario = productoSeleccionado!.precio;
    double descuentoAplicado = 0;

    if (tipoDescuento == 'Monto fijo') {
      if (descuentoInput > precioUnitario) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "El descuento no puede superar el precio.",
          ),
        );
        return;
      }
      descuentoAplicado = descuentoInput;
    } else if (tipoDescuento == 'Porcentaje') {
      if (descuentoInput > 100) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(message: "El porcentaje no puede superar 100."),
        );
        return;
      }
      descuentoAplicado = (precioUnitario * descuentoInput / 100);
    }
    final precioConDescuento = (precioUnitario - descuentoAplicado) * cantidad;

    final detalle = DetalleVentaServicio(
      id: detalleId,
      ventaServicioId: widget.venta.id!,
      productoServicioId: productoSeleccionado!.id!,
      cantidad: cantidad,
      descuento: descuentoAplicado,
      subtotal: precioConDescuento,
    );

    if (detalleId == null) {
      final id = await repo.insert(detalle.toMap());
      idsTemporales.add(id);
    } else {
      await repo.update(detalle.toMap());
    }

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

  Future<void> eliminarDetalle(int id) async {
    if (await formEliminar(context, "este Registro")) {
      await repo.delete(id);
      cargarTodo();
    }
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
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.deepPurple[400],
          centerTitle: true,
          title: Text(
            'Detalle de venta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -6, end: -4),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.redAccent,
                  padding: EdgeInsets.all(6),
                  shape: badges.BadgeShape.circle,
                ),
                badgeContent: Text(
                  detalles.length.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.inventory_2_outlined, color: Colors.black87),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => DetallesDialog(
                            detalles: detalles,
                            productos: productos,
                            total: totalVenta(),
                          ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              // Información de la venta
              VentaInfoCard(venta: widget.venta),
              Divider(height: 32),

              // Formulario para agregar/editar productos
              DetalleForm(
                categorias: categorias,
                productosFiltrados: productosFiltrados,
                categoriaSeleccionadaId: categoriaSeleccionadaId,
                productoSeleccionado: productoSeleccionado,
                tipoDescuento: tipoDescuento,
                tiposDescuento: tiposDescuento,
                cantidadController: cantidadController,
                precioController: precioController,
                descuentoController: descuentoController,
                onGuardar: () {
                  if (detalleEditando == null) {
                    guardarDetalle();
                  } else {
                    guardarDetalle(detalleId: detalleEditando!.id);
                  }
                },
                onCancelarEdicion:
                    detalleEditando != null
                        ? () {
                          setState(() {
                            detalleEditando = null;
                            cantidadController.clear();
                            descuentoController.text = '0';
                            precioController.text = '0';
                            productoSeleccionado = null;
                          });
                        }
                        : null,
                onCategoriaChanged: filtrarProductosPorCategoria,
                onProductoChanged: (val) {
                  setState(() {
                    productoSeleccionado = val;
                    precioController.text =
                        val?.precio.toStringAsFixed(2) ?? '';
                  });
                },
                onTipoDescuentoChanged: (val) {
                  setState(() {
                    tipoDescuento = val!;
                  });
                },
              ),
              Divider(height: 32),

              // Lista de detalles ya agregados
              GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: detalles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.80,
                ),
                itemBuilder: (context, i) {
                  final d = detalles[i];
                  final producto = productos.firstWhere(
                    (p) => p.id == d.productoServicioId,
                  );
                  return DetalleCard(
                    detalle: d,
                    producto: producto,
                    onEditar: () {
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
                    onEliminar: () => eliminarDetalle(d.id!),
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
                    onPressed:
                        idsTemporales.isEmpty
                            ? null
                            : () {
                              setState(() {
                                idsTemporales.clear();
                              });
                              showTopSnackBar(
                                Overlay.of(context),
                                animationDuration: Duration(seconds: 1),
                                displayDuration: Duration(seconds: 1),
                                reverseAnimationDuration: Duration(seconds: 1),
                                CustomSnackBar.success(
                                  message: "Guardado Exitoso",
                                ),
                              );
                            },
                    icon: Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      'Guardar registros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      elevation: 6,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.greenAccent,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
