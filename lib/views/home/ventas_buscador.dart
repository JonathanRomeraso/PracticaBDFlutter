import 'package:flutter/material.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/views/home/ventas_data_table.dart';

class VentasDataTableConBuscador extends StatefulWidget {
  final List<VentaServicio> ventas;
  final TextEditingController searchController;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function<T>(
    Comparable<T> Function(VentaServicio venta),
    int columnIndex,
    bool ascending,
  ) onOrdenar;
  final Function(VentaServicio) onEdit;
  final Function(VentaServicio) onDelete;
  final Function(VentaServicio, String) onEstadoChange;

  const VentasDataTableConBuscador({
    super.key,
    required this.ventas,
    required this.searchController,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onOrdenar,
    required this.onEdit,
    required this.onDelete,
    required this.onEstadoChange,
  });

  @override
  State<VentasDataTableConBuscador> createState() => _VentasDataTableConBuscadorState();
}

class _VentasDataTableConBuscadorState extends State<VentasDataTableConBuscador> {
  String busqueda = '';
  List<VentaServicio> listaMostrada = [];

  @override
  void initState() {
    super.initState();
    aplicarBusqueda('');
  }

  void aplicarBusqueda(String query) {
    busqueda = query.toLowerCase();
    setState(() {
      listaMostrada = widget.ventas.where((venta) {
        return venta.titulo.toLowerCase().contains(busqueda) ||
            venta.descripcion.toLowerCase().contains(busqueda) ||
            venta.nombreCliente.toLowerCase().contains(busqueda) ||
            venta.fecha.toLowerCase().contains(busqueda);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              labelText: 'Buscar ventas o servicios',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        aplicarBusqueda('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: aplicarBusqueda,
          ),
        ),
        Expanded(
          child: VentasDataTable(
            ventas: listaMostrada,
            sortColumnIndex: widget.sortColumnIndex,
            sortAscending: widget.sortAscending,
            onOrdenar: widget.onOrdenar,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            onEstadoChange: widget.onEstadoChange,
            context: context,
          ),
        ),
      ],
    );
  }
}
