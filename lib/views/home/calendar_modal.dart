import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class CalendarModal extends StatelessWidget {
  final Map<DateTime, List<VentaServicio>> eventos;
  final void Function(DateTime fecha, List<VentaServicio> eventosDelDia)
  onDaySelected;

  const CalendarModal({
    super.key,
    required this.eventos,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
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
            child: TableCalendar(
              onFormatChanged: (_) {},
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: DateTime.now(),
              eventLoader:
                  (day) =>
                      eventos[DateTime(day.year, day.month, day.day)] ?? [],
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
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (restantes > 0)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple.shade600,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.shade900,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                '+',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, _) {
                final eventosDelDia =
                    eventos[DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    )] ??
                    [];
                onDaySelected(selectedDay, eventosDelDia);
              },
            ),
          ),
        ],
      ),
    );
  }
}
