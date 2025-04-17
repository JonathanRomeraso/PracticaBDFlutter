import 'package:flutter/material.dart';
import 'package:practica_tres/models/detalle_venta_servicio.dart';
import 'package:practica_tres/models/producto_servicio.dart';

class DetallesDialog extends StatelessWidget {
  final List<DetalleVentaServicio> detalles;
  final List<ProductoServicio> productos;
  final double total;

  const DetallesDialog({
    super.key,
    required this.detalles,
    required this.productos,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Bienes agregados',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: detalles.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final d = detalles[index];
                  final producto = productos.firstWhere(
                    (p) => p.id == d.productoServicioId,
                  );
                  return ListTile(
                    title: Text(
                      producto.nombre,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Cantidad: ${d.cantidad}'),
                    trailing: Text(
                      '\$${d.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Total:   \$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cerrar', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
