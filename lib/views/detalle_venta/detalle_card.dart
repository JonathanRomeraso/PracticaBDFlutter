import 'package:flutter/material.dart';
import 'package:practica_tres/models/detalle_venta_servicio.dart';
import 'package:practica_tres/models/producto_servicio.dart';
import 'package:practica_tres/views/info_row.dart';

class DetalleCard extends StatelessWidget {
  final DetalleVentaServicio detalle;
  final ProductoServicio producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const DetalleCard({
    super.key,
    required this.detalle,
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = producto.precio * detalle.cantidad;
    final descuentoTotal = detalle.descuento * detalle.cantidad;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      shadowColor: Colors.deepPurpleAccent[400],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: onEditar,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: onEliminar,
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 4),
            infoRow(
              Icons.attach_money,
              'Precio: \$${producto.precio.toStringAsFixed(2)}',
            ),
            infoRow(
              Icons.format_list_numbered,
              'Cantidad: ${detalle.cantidad}',
            ),
            infoRow(
              Icons.calculate_outlined,
              'Subtotal: \$${subtotal.toStringAsFixed(2)}',
              color: Colors.blueAccent[700],
            ),
            infoRow(
              Icons.remove_circle_outline,
              'Descuento: \$${descuentoTotal.toStringAsFixed(2)}',
              color: Colors.orange,
            ),
            infoRow(
              Icons.payments_outlined,
              'Total: \$${detalle.subtotal.toStringAsFixed(2)}',
              color: Colors.green[700],
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
