import 'package:flutter/material.dart';
import 'package:practica_tres/db/venta_servicio_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/screens/detalle_venta_screen.dart';
import 'package:practica_tres/services/notification_service.dart';

class VentasServiciosScreen extends StatefulWidget {
  const VentasServiciosScreen({super.key});

  @override
  State<VentasServiciosScreen> createState() => _VentasServiciosScreenState();
}

class _VentasServiciosScreenState extends State<VentasServiciosScreen> {
  final _formKey = GlobalKey<FormState>();
  final repo = VentaServicioDatabase();

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final clienteController = TextEditingController();
  final recordatorioController = TextEditingController();
  DateTime? fecha = DateTime.now();

  Future<void> guardarVenta() async {
    if (_formKey.currentState!.validate()) {
      final nuevaVenta = VentaServicio(
        titulo: tituloController.text.trim(),
        descripcion: descripcionController.text.trim(),
        nombreCliente: clienteController.text.trim(),
        recordatorio: 2,
        fecha: fecha?.toIso8601String() ?? DateTime.now().toIso8601String(),
        estatus: 'Por cumplir',
      );
      //await repo.insert(nuevaVenta.toMap());
      final id = await repo.insert(nuevaVenta.toMap());
      final ventaInsertada = nuevaVenta.copyWith(id: id);
      DateTime recordatorio2DiasAntes = DateTime(
        fecha!.year,
        fecha!.month,
        fecha!.day - 2,
        DateTime.now().hour,
        DateTime.now().minute + 1,
        DateTime.now().second + 5,
      );

      if (recordatorio2DiasAntes.isAfter(DateTime.now())) {
        await notificationProgramada(
          recordatorio2DiasAntes,
          tituloController.text.trim(),
          descripcionController.text.trim(),
          clienteController.text.trim(),
          '${fecha?.toLocal().toString().split(' ')[0]}',
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleVentaScreen(venta: ventaInsertada),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Agregar Venta/Servicio'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          color: Colors.white,
          shadowColor: Colors.purple.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Completar los campos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: tituloController,
                    decoration: InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: InputDecoration(labelText: 'Descripción'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: clienteController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Cliente',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre del cliente es obligatorio';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Fecha: ${fecha?.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
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
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: guardarVenta,
                    icon: Icon(Icons.save),
                    label: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
