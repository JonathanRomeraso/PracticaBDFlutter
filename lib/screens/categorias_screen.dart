import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:practica_tres/db/categorias_database.dart';
import 'package:practica_tres/models/categoria.dart';
import 'package:practica_tres/views/form_eliminar.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});
  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final category = CategoriasDatabase();
  List<Categoria> categorias = [];

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    final data = await category.getAll();
    setState(() {
      categorias = data;
    });
  }

  Future<void> mostrarFormulario({Categoria? categoria}) async {
    final conNombreCategoria = TextEditingController(
      text: categoria?.nombre ?? '',
    );
    final isEdit = categoria != null;

    await showDialog(
      context: context,
      builder: (_) {
        String? selectedType = isEdit ? categoria.type : 'Servicio';
        return AlertDialog(
          title: Text(isEdit ? 'Editar Categoría' : 'Nueva Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: conNombreCategoria,
                decoration: InputDecoration(hintText: 'Nombre de la categoría'),
              ),
              SizedBox(height: 35),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'Servicio', child: Text('Servicio')),
                  DropdownMenuItem(value: 'Producto', child: Text('Producto')),
                ],
                onChanged: (value) {
                  selectedType = value;
                },
                decoration: InputDecoration(
                  labelText: 'Tipo de categoría',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final nombre = conNombreCategoria.text.trim();
                if (nombre.isEmpty) return;

                if (isEdit) {
                  categoria.nombre = nombre;
                  await category.update({
                    'nombre': nombre,
                    'id': categoria.id,
                    'type': selectedType,
                  });
                } else {
                  await category.insert({
                    'nombre': nombre,
                    'type': selectedType,
                  });
                }
                Navigator.pop(context);
                cargarCategorias();
              },
              child: Text(isEdit ? 'Actualizar' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarCategoria(int id) async {
    if (await formEliminar(context, "esta Categoría")) {
      await category.delete(id);
      cargarCategorias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Categorías',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            icon: Icon(Icons.add_circle_outline, size: 35, color: Colors.green),
            tooltip: 'Agregar Categoría',
            onPressed: () => mostrarFormulario(),
          ),
        ],
      ),
      body:
          categorias.isEmpty
              ? Center(child: Text('No hay productos o servicios'))
              : _listaProductosServicios(categorias),
    );
  }

  Widget _listaProductosServicios(List<Categoria> categorias) {
    return GroupedListView<Categoria, String>(
      elements: categorias,
      groupBy: (categoria) => categoria.type,
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) => item1.nombre.compareTo(item2.nombre),
      order: GroupedListOrder.DESC,
      useStickyGroupSeparators: true,
      groupSeparatorBuilder:
          (String value) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
      itemBuilder: (context, categoria) {
        return Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            leading: const Icon(Icons.category_rounded, color: Colors.blue),
            title: Text(categoria.nombre),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => mostrarFormulario(categoria: categoria),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => eliminarCategoria(categoria.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
