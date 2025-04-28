import 'package:flutter/material.dart';
import 'package:practica_tres/db/categorias_database.dart';
import 'package:practica_tres/models/categoria.dart';
import 'package:practica_tres/views/form_eliminar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
    final puedeEliminar = await category.puedeEliminarCategoria(id);

    if (puedeEliminar) {
      if (await formEliminar(context, "esta Categoría")) {
        await category.delete(id);
        cargarCategorias();
      }
    } else {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message:
              "No se puede eliminar esta categoría, tiene productos asociados",
        ),
      );
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
              ? Center(child: Text('No hay Categorías disponibles'))
              : _listaProductosServicios(categorias),
    );
  }

  Widget _listaProductosServicios(List<Categoria> categorias) {
    final grupos = <String, List<Categoria>>{};
    for (var cat in categorias) {
      grupos.putIfAbsent(cat.type, () => []).add(cat);
    }

    return ListView(
      children:
          grupos.entries.map((entry) {
            entry.value.sort((a, b) => a.nombre.compareTo(b.nombre));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        entry.value.map((categoria) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: Card(
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: const Icon(
                                            Icons.category_rounded,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            categoria.nombre,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                          ),
                                          onPressed:
                                              () => mostrarFormulario(
                                                categoria: categoria,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => eliminarCategoria(
                                                categoria.id!,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
