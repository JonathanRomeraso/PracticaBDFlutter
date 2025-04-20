import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/views/home/ventas_data_source.dart';

class VentasDataTable extends StatelessWidget {
  final List<VentaServicio> ventas;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(Comparable Function(VentaServicio), int, bool) onOrdenar;
  final void Function(VentaServicio) onEdit;
  final void Function(VentaServicio) onDelete;
  final void Function(VentaServicio, String) onEstadoChange;
  final BuildContext context;

  const VentasDataTable({
    super.key,
    required this.ventas,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onOrdenar,
    required this.onEdit,
    required this.onDelete,
    required this.onEstadoChange,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final source = VentasDataSource(
      ventas: ventas,
      onEdit: onEdit,
      onDelete: (venta) => onDelete(venta),
      onEstadoChange: onEstadoChange,
      context: this.context,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 550),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: PaginatedDataTable2(
          headingRowColor: WidgetStateProperty.all(Colors.purple.shade400),
          headingRowDecoration: BoxDecoration(
            color: Colors.purple.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.purple.shade100,
              width: 1,
            ),
            verticalInside: BorderSide(color: Colors.purple.shade100, width: 1),
          ),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          dataTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),
          header: const Text('Ventas y Servicios'),
          rowsPerPage: 8,
          renderEmptyRowsInTheEnd: true,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          sortArrowIconColor: Colors.white,
          sortArrowIcon: Icons.keyboard_arrow_up,
          columnSpacing: 10,
          minWidth: 1000,
          dataRowHeight: 80,
          columns: [
            const DataColumn2(
              label: Center(child: Text('Editar')),
              fixedWidth: 60,
            ),
            const DataColumn2(
              label: Center(child: Text('Estado')),
              fixedWidth: 60,
            ),
            DataColumn(
              label: const Center(child: Text('Título')),
              onSort:
                  (columnIndex, ascending) => onOrdenar(
                    (venta) => venta.titulo.toLowerCase(),
                    columnIndex,
                    ascending,
                  ),
            ),
            DataColumn(
              label: const Center(child: Text('Estado')),
              onSort:
                  (columnIndex, ascending) => onOrdenar(
                    (venta) => venta.estatus.toLowerCase(),
                    columnIndex,
                    ascending,
                  ),
            ),
            DataColumn(
              label: const Center(child: Text('Fecha')),
              onSort:
                  (columnIndex, ascending) => onOrdenar(
                    (venta) => DateTime.parse(venta.fecha),
                    columnIndex,
                    ascending,
                  ),
            ),
            const DataColumn(label: Center(child: Text('Descripción'))),
            DataColumn(
              label: const Center(child: Text('Cliente')),
              onSort:
                  (columnIndex, ascending) => onOrdenar(
                    (venta) => venta.nombreCliente.toLowerCase(),
                    columnIndex,
                    ascending,
                  ),
            ),
            const DataColumn2(
              label: Center(child: Text('Ver')),
              fixedWidth: 45,
            ),
            const DataColumn2(
              label: Center(child: Text('Eliminar')),
              fixedWidth: 60,
            ),
          ],
          source: source,
        ),
      ),
    );
  }
}
