import 'package:flutter/material.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class VentaInfoCard extends StatelessWidget {
  final VentaServicio venta;

  const VentaInfoCard({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.deepPurpleAccent[400],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart_outlined, color: Colors.blueAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    venta.titulo,
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
              venta.descripcion,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            Divider(height: 24, thickness: 1.2),
            Row(
              children: [
                Icon(Icons.person_outline, size: 20, color: Colors.grey[600]),
                SizedBox(width: 6),
                Text(
                  'Cliente: ${venta.nombreCliente}',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
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
                  'Fecha: ${venta.fecha.split('T').first}',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
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
                  'Estatus: ${venta.estatus}',
                  style: TextStyle(
                    fontSize: 15,
                    color: getColorByEstatus(venta.estatus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getColorByEstatus(String estatus) {
    switch (estatus) {
      case 'Completada':
        return Colors.green;
      case 'Por cumplir':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
