//import 'package:dark_light_button/dark_light_button.dart';

import 'package:flutter/material.dart';
import 'package:practica_tres/db/venta_servicio_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/services/notification_service.dart';
import 'package:practica_tres/views/form_eliminar.dart';
import 'package:practica_tres/views/home/calendar_modal.dart';
import 'package:practica_tres/views/home/eventos_modal.dart';
import 'package:practica_tres/views/home/filtro_estado_dropdown.dart';
import 'package:practica_tres/views/home/venta_form_dialog.dart';
import 'package:practica_tres/views/home/ventas_data_table.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  final TextEditingController _searchController = TextEditingController();
  String busqueda = '';
  List<VentaServicio> listaMostrada = [];

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
        if (ventas.isEmpty) {
          ventas = todasLasVentas;
          showTopSnackBar(
            Overlay.of(context),
            animationDuration: Duration(seconds: 1),
            displayDuration: Duration(seconds: 1),
            reverseAnimationDuration: Duration(seconds: 1),
            CustomSnackBar.info(
              message:
                  'No hay ventas/servicios con el estado "$_estadoSeleccionado"',
            ),
          );
          _estadoSeleccionado = "Todos";
        }
      }
    });
  }

  Future<void> mostrarFormulario({VentaServicio? venta}) async {
    await showDialog(
      context: context,
      builder:
          (_) => VentaFormDialog(
            venta: venta,
            onSubmit: (nuevaVenta) async {
              if (venta == null) {
                await repo.insert(nuevaVenta.toMap());
              } else {
                await repo.update(nuevaVenta.toMap());

                DateTime fecha = DateTime.parse(nuevaVenta.fecha);
                DateTime recordatorio2DiasAntes = DateTime(
                  fecha.year,
                  fecha.month,
                  fecha.day - 2,
                  DateTime.now().hour,
                  DateTime.now().minute + 1,
                  DateTime.now().second + 5,
                );
                if (recordatorio2DiasAntes.isAfter(DateTime.now())) {
                  await notificationProgramada(
                    recordatorio2DiasAntes,
                    nuevaVenta.titulo,
                    nuevaVenta.descripcion,
                    nuevaVenta.nombreCliente,
                    fecha.toLocal().toString().split(' ')[0],
                  );
                }
              }
              cargarVentas();
            },
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

  void _mostrarCalendarioEnModal() {
    final eventos = eventosPorFecha();
    showDialog(
      context: context,
      builder:
          (context) => CalendarModal(
            eventos: eventos,
            onDaySelected: (fecha, eventosDelDia) {
              //Navigator.pop(context);
              _mostrarModalEventos(context, fecha, eventosDelDia);
            },
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
      builder: (_) => EventosModal(fecha: fecha, eventos: eventos),
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
              accountName: Text("Jonathan Rodriguez"),
              accountEmail: Text("21030021@itcelaya.edu.mx"),
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
                            color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Botón para agregar venta/servicio
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed:
                                () => Navigator.pushNamed(
                                  context,
                                  "/ventasServicios",
                                ),
                            icon: Icon(
                              Icons.add_circle_sharp,
                              color: Colors.purple.shade900,
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
                              elevation: 15,
                              shadowColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                            ),
                          ),
                        ),
                        // Botón para ver calendario
                        SizedBox(
                          height: 75,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: _mostrarCalendarioEnModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                elevation: 8,
                                shadowColor: Colors.deepPurpleAccent,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Center(
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DataTable con buscador y filtros
                  Expanded(child: ventasDataTableConBuscador()),
                ],
              ),
    );
  }

  Widget ventasDataTableConBuscador() {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        int? localSortColumnIndex = _sortColumnIndex;
        bool localSortAscending = _sortAscending;
        void aplicarBusqueda(String query) {
          busqueda = query.toLowerCase();
          listaMostrada =
              ventas.where((venta) {
                return venta.titulo.toLowerCase().contains(busqueda) ||
                    venta.descripcion.toLowerCase().contains(busqueda) ||
                    venta.nombreCliente.toLowerCase().contains(busqueda) ||
                    venta.fecha.toLowerCase().contains(busqueda);
              }).toList();
        }

        aplicarBusqueda(busqueda);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros y búsqueda
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.deepPurpleAccent.shade100,
                    width: 1,
                  ),
                ),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.deepPurpleAccent.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Filtro de estado
                        Expanded(
                          flex: 2,
                          child: FiltroEstadoDropdown(
                            estados: _estados,
                            estadoSeleccionado: _estadoSeleccionado,
                            onChanged: (value) {
                              setState(() {
                                _estadoSeleccionado = value;
                                aplicarFiltro();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Buscador
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Buscar',
                                prefixIcon: const Icon(
                                  Icons.manage_search_sharp,
                                ),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setInnerState(() {
                                              busqueda = '';
                                            });
                                          },
                                        )
                                        : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                setInnerState(() {
                                  aplicarBusqueda(value);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // DataTable
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurpleAccent.shade100,
                      width: 1,
                    ),
                  ),
                  child: Card(
                    elevation: 15,
                    shadowColor: Colors.deepPurpleAccent.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: VentasDataTable(
                      ventas: listaMostrada,
                      sortColumnIndex: localSortColumnIndex,
                      sortAscending: localSortAscending,
                      onOrdenar: _ordenar,
                      onEdit: (venta) => mostrarFormulario(venta: venta),
                      onDelete: (venta) => eliminarVenta(venta.id!),
                      onEstadoChange: cambiarEstado,
                      context: context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
