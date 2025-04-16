import 'package:flutter/material.dart';
import 'package:practica_tres/db/venta_servicio_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class VentasServiciosScreen extends StatefulWidget {
  const VentasServiciosScreen({super.key});

  @override
  State<VentasServiciosScreen> createState() => _VentasServiciosScreenState();
}

class _VentasServiciosScreenState extends State<VentasServiciosScreen> {
  final repo = VentaServicioDatabase();
  List<VentaServicio> ventas = [];

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
                    decoration: InputDecoration(
                      labelText: 'Nombre del Cliente',
                    ),
                  ),
                  TextField(
                    controller: recordatorioController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Días de recordatorio',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
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
                    icon: Icon(Icons.date_range),
                    label: Text('Seleccionar fecha'),
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
                  final nuevaVenta = VentaServicio(
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
                    await repo.insert(nuevaVenta.toMap());
                  } else {
                    await repo.update(nuevaVenta.toMap());
                  }

                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, "/home");
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Ventas / Servicios'),
            floating: true,
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => mostrarFormulario(),
              ),
            ],
          ),
          ventas.isEmpty
              ? SliverFillRemaining(
                child: Center(child: Text('No hay ventas registradas')),
              )
              : SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final venta = ventas[index];
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venta.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(venta.descripcion),
                            SizedBox(height: 4),
                            Text('Cliente: ${venta.nombreCliente}'),
                            Text('Fecha: ${venta.fecha.split('T').first}'),
                            Text('Estado: ${venta.estatus.toUpperCase()}'),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    cambiarEstado(venta, value);
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'proceso',
                                          child: Text('En proceso'),
                                        ),
                                        PopupMenuItem(
                                          value: 'completado',
                                          child: Text('Completado'),
                                        ),
                                        PopupMenuItem(
                                          value: 'cancelado',
                                          child: Text('Cancelado'),
                                        ),
                                      ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed:
                                          () => mostrarFormulario(venta: venta),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => eliminarVenta(venta.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: ventas.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
