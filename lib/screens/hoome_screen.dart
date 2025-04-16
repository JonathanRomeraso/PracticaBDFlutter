//import 'package:dark_light_button/dark_light_button.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:practica_tres/db/venta_servicio_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/screens/detalle_venta_screen.dart';

class HoomeScreen extends StatefulWidget {
  const HoomeScreen({super.key});

  @override
  State<HoomeScreen> createState() => _HoomeScreenState();
}

class _HoomeScreenState extends State<HoomeScreen> {
  final repo = VentaServicioDatabase();
  List<VentaServicio> ventas = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    cargarVentas();
  }

  Future<void> cargarVentas() async {
    final data = await repo.select();
    setState(() {
      ventas = data;
    });
  }

  Future<void> mostrarFormulario({VentaServicio? venta}) async {
    final tituloController = TextEditingController(text: venta?.titulo ?? '');
    final descripcionController = TextEditingController(
      text: venta?.descripcion ?? '',
    );
    final clienteController = TextEditingController(
      text: venta?.nombreCliente ?? '',
    );
    final recordatorioController = TextEditingController(
      text: venta?.recordatorio.toString() ?? '',
    );
    DateTime? fecha =
        venta != null ? DateTime.tryParse(venta.fecha) : DateTime.now();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              venta == null ? 'Nueva Venta/Servicio' : 'Editar Venta/Servicio',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: InputDecoration(labelText: 'Título'),
                  ),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: clienteController,
                    decoration: InputDecoration(labelText: 'Cliente'),
                  ),
                  TextField(
                    controller: recordatorioController,
                    decoration: InputDecoration(
                      labelText: 'Recordatorio (días)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.date_range),
                    label: Text('Seleccionar Fecha'),
                    onPressed: () async {
                      final seleccion = await showDatePicker(
                        context: context,
                        initialDate: fecha ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (seleccion != null) {
                        setState(() {
                          fecha = seleccion;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final nueva = VentaServicio(
                    id: venta?.id,
                    titulo: tituloController.text.trim(),
                    descripcion: descripcionController.text.trim(),
                    nombreCliente: clienteController.text.trim(),
                    recordatorio:
                        int.tryParse(recordatorioController.text.trim()) ?? 0,
                    fecha:
                        fecha?.toIso8601String() ??
                        DateTime.now().toIso8601String(),
                    estatus: venta?.estatus ?? 'pendiente',
                  );

                  if (venta == null) {
                    await repo.insert(nueva.toMap());
                  } else {
                    await repo.update(nueva.toMap());
                  }

                  Navigator.pop(context);
                  cargarVentas();
                },
                child: Text(venta == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
    );
  }

  Future<void> cambiarEstado(VentaServicio venta, String nuevoEstado) async {
    venta.estatus = nuevoEstado;
    await repo.update(venta.toMap());
    cargarVentas();
  }

  Future<void> eliminarVenta(int id) async {
    await repo.delete(id);
    cargarVentas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Productos y Servicios",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://www.w3schools.com/howto/img_avatar.png",
                ),
              ),
              accountName: Text("Nombre de Usuario"),
              accountEmail: Text("Correo de Usuario"),
            ),
            ListTile(
              leading: Icon(Icons.storage),
              title: Text("Categorías"),
              subtitle: Text("Ver y editar categorías"),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/categorias");
                },
                child: Icon(Icons.chevron_right),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.shopping_cart_rounded),
              title: Text("Bienes y Servicios"),
              subtitle: Text("Ver y editar bienes y servicios"),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/bienes");
                },
                child: Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
      body:
          ventas.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bienvenido a la App de Productos y Servicios",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/ventasServicios");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade400,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text("Agregar Venta/Servicio"),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed:
                          () =>
                              Navigator.pushNamed(context, "/ventasServicios"),
                      icon: Icon(
                        Icons.add_circle_sharp,
                        color: Colors.purple[600],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.purple.shade400,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      label: Text(
                        "Agregar Venta/Servicio",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Flexible(child: _dataTables()),
                ],
              ),
    );
  }

  Widget _dataTables() {
    final source = VentasDataSource(
      ventas: ventas,
      onEdit: (venta) => mostrarFormulario(venta: venta),
      onEstadoChange: cambiarEstado,
      context: context,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 600),
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

          headingTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          dataTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),

          header: Text('Ventas y Servicios'),
          rowsPerPage: 5,
          renderEmptyRowsInTheEnd: true,

          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          sortArrowIconColor: Colors.white,
          sortArrowIcon: Icons.keyboard_arrow_up,

          columnSpacing: 10,
          minWidth: 1000,
          dataRowHeight: 80,
          columns: [
            DataColumn2(label: Center(child: Text('Editar')), fixedWidth: 60),
            DataColumn2(label: Center(child: Text('Estado')), fixedWidth: 60),
            DataColumn(
              label: Center(child: Text('Título')),
              onSort:
                  (columnIndex, ascending) => _ordenar(
                    (venta) => venta.titulo.toLowerCase(),
                    columnIndex,
                    ascending,
                  ),
            ),
            DataColumn(
              label: Center(child: Text('Estado')),
              onSort:
                  (columnIndex, ascending) => _ordenar(
                    (venta) => venta.estatus.toLowerCase(),
                    columnIndex,
                    ascending,
                  ),
            ),
            DataColumn(
              label: Center(child: Text('Fecha')),
              onSort:
                  (columnIndex, ascending) => _ordenar(
                    (venta) => DateTime.parse(venta.fecha),
                    columnIndex,
                    ascending,
                  ),
            ),
            DataColumn(label: Center(child: Text('Descripción'))),
            DataColumn(
              label: Center(child: Text('Cliente')),
              onSort:
                  (columnIndex, ascending) => _ordenar(
                    (venta) => venta.nombreCliente.toLowerCase(),
                    columnIndex,
                    ascending,
                  ),
            ),
            DataColumn2(label: Center(child: Text('Ver')), fixedWidth: 60),
          ],
          source: source,
        ),
      ),
    );
  }

  void _ordenar<T>(
    Comparable<T> Function(VentaServicio venta) getField,
    int columnIndex,
    bool ascending,
  ) {
    ventas.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}

class StatusData {
  final Color color;
  final IconData icon;
  final Color textColor;
  final bool hasBorder;

  StatusData({
    required this.color,
    required this.icon,
    required this.textColor,
    this.hasBorder = false,
  });
}

class VentasDataSource extends DataTableSource {
  final List<VentaServicio> ventas;
  final Function(VentaServicio venta) onEdit;
  final Function(VentaServicio venta, String estado) onEstadoChange;
  final BuildContext context;
  final repo = VentaServicioDatabase();

  VentasDataSource({
    required this.ventas,
    required this.onEdit,
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
                      value: 'Completado',
                      child: Text('Completado'),
                    ),
                    PopupMenuItem(value: 'Cancelado', child: Text('Cancelado')),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleVentaScreen(venta: ver),
                  ),
                );
              },
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
      case 'completado':
        return StatusData(
          color: Colors.white,
          icon: Icons.check_circle,
          textColor: Colors.black,
          hasBorder: true,
        );
      case 'cancelado':
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
      case 'completado':
        return Colors.grey[200]!;
      case 'cancelado':
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
