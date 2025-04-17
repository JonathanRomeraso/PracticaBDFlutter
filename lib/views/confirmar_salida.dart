import 'package:flutter/material.dart';

Future<bool> confirmarSalida(context, idsTemporales) async {
  if (idsTemporales.isEmpty) return true;

  final salir = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Registros sin confirmar'),
          content: Text(
            'Tienes productos/servicios agregados que no se han confirmado. '
            '¿Deseas salir y descartarlos?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Salir de todos modos'),
            ),
          ],
        ),
  );

  return salir ?? false;
}
