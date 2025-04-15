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

  Future<void> agregarVenta() async {
    final nuevaVenta = VentaServicio(
      titulo: 'Servicio Demo',
      descripcion: 'Descripción de ejemplo',
      fecha: DateTime.now().toString(),
      estatus: 'pendiente',
      recordatorio: DateTime.now().add(Duration(days: 2)).millisecondsSinceEpoch,
      nombreCliente: 'Cliente de Prueba',
      //total: 150.0,
    );

    //await repo.insert(nuevaVenta);
    cargarVentas();
  }

  Future<void> actualizarVenta(VentaServicio venta) async {
    venta.estatus = 'completado';
    //await repo.update(venta);
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
        title: Text('Ventas/Servicios'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: agregarVenta,
          ),
        ],
      ),
      body: ventas.isEmpty
          ? Center(child: Text('No hay ventas registradas'))
          : ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                final venta = ventas[index];
                return ListTile(
                  title: Text(venta.titulo),
                  subtitle: Text('${venta.descripcion}\nEstado: ${venta.estatus}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => actualizarVenta(venta),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarVenta(venta.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
