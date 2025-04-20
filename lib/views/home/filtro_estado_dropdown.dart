import 'package:flutter/material.dart';

class FiltroEstadoDropdown extends StatelessWidget {
  final List<String> estados;
  final String? estadoSeleccionado;
  final void Function(String?) onChanged;

  const FiltroEstadoDropdown({
    super.key,
    required this.estados,
    required this.estadoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: DropdownButtonFormField<String>(
        value: estadoSeleccionado ?? 'Todos',
        decoration: InputDecoration(
          labelText: 'Filtrar por estado',
          labelStyle: const TextStyle(
            color: Colors.deepPurple,
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
            borderSide: BorderSide(color: Colors.purple.shade300),
          ),
        ),
        items:
            estados.map((estado) {
              return DropdownMenuItem<String>(
                value: estado,
                child: Text(estado, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.purple),
      ),
    );
  }
}
