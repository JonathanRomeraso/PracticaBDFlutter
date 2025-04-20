import 'package:flutter/material.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class VentaFormDialog extends StatefulWidget {
  final VentaServicio? venta;
  final void Function(VentaServicio nuevaVenta) onSubmit;

  const VentaFormDialog({super.key, this.venta, required this.onSubmit});

  @override
  State<VentaFormDialog> createState() => _VentaFormDialogState();
}

class _VentaFormDialogState extends State<VentaFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController tituloController;
  late TextEditingController descripcionController;
  late TextEditingController clienteController;
  late TextEditingController recordatorioController;
  DateTime? fecha;

  @override
  void initState() {
    super.initState();
    final venta = widget.venta;
    tituloController = TextEditingController(text: venta?.titulo ?? '');
    descripcionController = TextEditingController(
      text: venta?.descripcion ?? '',
    );
    clienteController = TextEditingController(text: venta?.nombreCliente ?? '');
    fecha = venta != null ? DateTime.tryParse(venta.fecha) : DateTime.now();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    clienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.venta == null ? 'Nueva Venta/Servicio' : 'Editar Venta/Servicio',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: clienteController,
                decoration: const InputDecoration(labelText: 'Cliente'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text('Seleccionar Fecha'),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final nueva = VentaServicio(
                id: widget.venta?.id,
                titulo: tituloController.text.trim(),
                descripcion: descripcionController.text.trim(),
                nombreCliente: clienteController.text.trim(),
                recordatorio: 2,
                fecha:
                    fecha?.toIso8601String() ??
                    DateTime.now().toIso8601String(),
                estatus: widget.venta?.estatus ?? 'Por Cumplir',
              );

              widget.onSubmit(nueva);
              Navigator.pop(context);
            }
          },
          child: Text(widget.venta == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }
}
