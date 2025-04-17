//import 'package:dark_light_button/dark_light_button.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:practica_tres/db/venta_servicio_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/views/form_eliminar.dart';
import 'package:practica_tres/views/home/ventas_data_source.dart';
import 'package:table_calendar/table_calendar.dart';

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
  List<VentaServicio> todasLasVentas = [];

  String? _estadoSeleccionado;
  final List<String> _estados = [
    'Todos',
    'Por cumplir',
    'Cancelada',
    'Completada',
  ];

  @override
  void initState() {
    super.initState();
    cargarVentas();
  }

  Future<void> cargarVentas() async {
    final data = await repo.select();
    setState(() {
      todasLasVentas = data;
      aplicarFiltro();
    });
  }

  void aplicarFiltro() {
    setState(() {
      if (_estadoSeleccionado == null || _estadoSeleccionado == 'Todos') {
        ventas = todasLasVentas;
      } else {
        ventas =
            todasLasVentas
                .where(
                  (venta) =>
                      venta.estatus.toLowerCase() ==
                      _estadoSeleccionado!.toLowerCase(),
                )
                .toList();
      }
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
    if (await formEliminar(context, "esta Venta/Servicio")) {
      await repo.delete(id);
      cargarVentas();
    }
  }

  Map<DateTime, List<VentaServicio>> eventosPorFecha() {
    final Map<DateTime, List<VentaServicio>> mapa = {};

    for (var venta in ventas) {
      final fecha = DateTime.parse(venta.fecha);
      final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
      mapa.putIfAbsent(soloFecha, () => []).add(venta);
    }

    return mapa;
  }

  Widget _buildCalendario() {
    final eventos = eventosPorFecha();
    return TableCalendar(
      onFormatChanged: (format) {},
      //weekNumbersVisible: false,
      headerStyle: HeaderStyle(formatButtonVisible: false),
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: DateTime.now(),
      eventLoader:
          (day) => eventos[DateTime(day.year, day.month, day.day)] ?? [],
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, eventosDelDia) {
          if (eventosDelDia.isEmpty) return null;
          const maxVisible = 4;
          final visibles =
              eventosDelDia.length > maxVisible
                  ? eventosDelDia.take(maxVisible - 1).toList()
                  : eventosDelDia;

          final restantes = eventosDelDia.length - visibles.length;
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...visibles.map((evento) {
                  final venta = evento as VentaServicio;
                  Color color;
                  switch (venta.estatus.toLowerCase()) {
                    case 'por cumplir':
                      color = Colors.green;
                      break;
                    case 'cancelada':
                      color = Colors.red;
                      break;
                    case 'completada':
                      color = Colors.white;
                      break;
                    default:
                      color = Colors.grey;
                  }
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color:
                            color == Colors.white
                                ? Colors.black
                                : Colors.transparent,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: .3),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  );
                }),
                // Marcador +X
                if (restantes > 0)
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(left: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple.shade600,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.shade900,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+$restantes',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        final eventosDelDia =
            eventos[DateTime(
              selectedDay.year,
              selectedDay.month,
              selectedDay.day,
            )] ??
            [];
        _mostrarModalEventos(context, selectedDay, eventosDelDia);
      },
    );
  }

  void _mostrarCalendarioEnModal() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Calendario de Ventas/Servicios',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCalendario(),
                ),
              ],
            ),
          ),
    );
  }

  void _mostrarModalEventos(
    BuildContext context,
    DateTime fecha,
    List<VentaServicio> eventos,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Eventos del ${fecha.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Cuerpo del modal
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child:
                      eventos.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                "No hay eventos.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            itemCount: eventos.length,
                            itemBuilder: (_, index) {
                              final e = eventos[index];

                              // Colores según estatus
                              Color statusColor;
                              IconData icon;
                              switch (e.estatus.toLowerCase()) {
                                case 'por cumplir':
                                  statusColor = Colors.green;
                                  icon = Icons.schedule;
                                  break;
                                case 'cancelada':
                                  statusColor = Colors.red;
                                  icon = Icons.cancel;
                                  break;
                                case 'completada':
                                  statusColor = Colors.blueGrey;
                                  icon = Icons.check_circle;
                                  break;
                                default:
                                  statusColor = Colors.grey;
                                  icon = Icons.info_outline;
                              }

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Icon(icon, color: statusColor),
                                  title: Text(
                                    e.titulo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(e.descripcion),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 50),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Text(
                                      e.estatus,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
    );
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Bienvenido a la App de Productos y Servicios",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, "/ventasServicios");
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Agregar Venta/Servicio",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade500,
                          elevation: 5,
                          shadowColor: Colors.purple.shade200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  // Botón para ver calendario
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _mostrarCalendarioEnModal,
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Ver Calendario",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        elevation: 6,
                        shadowColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Botón para agregar venta/servicio
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed:
                          () =>
                              Navigator.pushNamed(context, "/ventasServicios"),
                      icon: Icon(
                        Icons.add_circle_sharp,
                        color: Colors.purple.shade600,
                      ),
                      label: const Text(
                        "Agregar Venta/Servicio",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.purple.shade200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.purple.shade200),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: DropdownButtonFormField<String>(
                        value: _estadoSeleccionado ?? 'Todos',
                        decoration: InputDecoration(
                          labelText: 'Filtrar por estado',
                          labelStyle: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.purple.shade300,
                            ),
                          ),
                        ),
                        items:
                            _estados.map((estado) {
                              return DropdownMenuItem<String>(
                                value: estado,
                                child: Text(
                                  estado,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _estadoSeleccionado = value;
                            aplicarFiltro();
                          });
                        },
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.purple),
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
      onDelete: (venta) => eliminarVenta(venta.id!),
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
            DataColumn2(label: Center(child: Text('Eliminar')), fixedWidth: 60),
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
