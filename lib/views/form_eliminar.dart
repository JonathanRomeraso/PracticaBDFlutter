import 'package:flutter/material.dart';

Future<bool> formEliminar(context, String tipo) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar $tipo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
  );
  return confirm ?? false;
}
