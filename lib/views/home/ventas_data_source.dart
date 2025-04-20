import 'package:flutter/material.dart';
import 'package:practica_tres/db/venta_servicio_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/views/BK/BackUp.dart';
import 'package:practica_tres/screens/detalle_venta_screen.dart';

class VentasDataSource extends DataTableSource {
  final List<VentaServicio> ventas;
  final Function(VentaServicio venta) onEdit;
  final Function(VentaServicio venta) onDelete;
  final Function(VentaServicio venta, String estado) onEstadoChange;
  final BuildContext context;
  final repo = VentaServicioDatabase();

  VentasDataSource({
    required this.ventas,
    required this.onEdit,
    required this.onDelete,
    required this.onEstadoChange,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= ventas.length) return null;
    final venta = ventas[index];

    return DataRow.byIndex(
      index: index,
      color: WidgetStateProperty.all(_getRowColor(venta.estatus)),
      cells: [
        DataCell(
          Center(
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () => onEdit(venta),
            ),
          ),
        ),
        DataCell(
          Center(
            child: PopupMenuButton<String>(
              icon: Icon(Icons.sync),
              onSelected: (estado) => onEstadoChange(venta, estado),
              itemBuilder:
                  (_) => [
                    PopupMenuItem(
                      value: 'Por Cumplir',
                      child: Text('Por Cumplir'),
                    ),
                    PopupMenuItem(
                      value: 'Completada',
                      child: Text('Completada'),
                    ),
                    PopupMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                  ],
            ),
          ),
        ),
        DataCell(Center(child: Text(venta.titulo))),
        DataCell(Center(child: buildStatusRow(venta.estatus))),
        DataCell(Center(child: Text(venta.fecha.split('T').first))),
        DataCell(Center(child: Text(venta.descripcion))),
        DataCell(Center(child: Text(venta.nombreCliente))),
        DataCell(
          Center(
            child: IconButton(
              icon: Icon(Icons.remove_red_eye_rounded, color: Colors.blue[900]),
              onPressed: () async {
                final ver = venta.copyWith(id: venta.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleVentaScreen(venta: ver),
                  ),
                );
              },
            ),
          ),
        ),
        DataCell(
          Center(
            child: IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => onDelete(venta),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatusRow(String estatus) {
    final statusData = _getStatusData(estatus);
    return SizedBox(
      height: 32,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusData.color,
          borderRadius: BorderRadius.circular(12),
          border:
              statusData.hasBorder
                  ? Border.all(color: Colors.grey.shade300)
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusData.icon, size: 16, color: statusData.textColor),
            const SizedBox(width: 4),
            Text(
              estatus.toUpperCase(),
              style: TextStyle(
                color: statusData.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusData _getStatusData(String estatus) {
    final lowerEstatus = estatus.toLowerCase();

    switch (lowerEstatus) {
      case 'por cumplir':
        return StatusData(
          color: Colors.green.shade700,
          icon: Icons.access_time,
          textColor: Colors.white,
        );
      case 'completada':
        return StatusData(
          color: Colors.white,
          icon: Icons.check_circle,
          textColor: Colors.black,
          hasBorder: true,
        );
      case 'cancelada':
        return StatusData(
          color: Colors.red.shade700,
          icon: Icons.cancel,
          textColor: Colors.white,
        );
      default:
        return StatusData(
          color: Colors.grey,
          icon: Icons.help_outline,
          textColor: Colors.white,
        );
    }
  }

  Color _getRowColor(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'completada':
        return Colors.grey[200]!;
      case 'cancelada':
        return Colors.red[100]!;
      case 'por cumplir':
        return Colors.green[100]!;
      default:
        return Colors.white;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ventas.length;

  @override
  int get selectedRowCount => 0;
}