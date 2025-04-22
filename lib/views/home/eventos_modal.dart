import 'package:flutter/material.dart';
import 'package:practica_tres/models/ventas_servicio.dart';
import 'package:practica_tres/screens/detalle_venta_screen.dart';

class EventosModal extends StatelessWidget {
  final DateTime fecha;
  final List<VentaServicio> eventos;

  const EventosModal({super.key, required this.fecha, required this.eventos});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

                        return GestureDetector(
                          onTap: () async {
                            final ver = e.copyWith(id: e.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleVentaScreen(venta: ver),
                              ),
                            );
                          },
                          child: Card(
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
                                  color: statusColor.withValues(alpha: .1),
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
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
