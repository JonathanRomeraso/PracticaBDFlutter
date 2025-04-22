import 'package:flutter/material.dart';
import 'package:practica_tres/db/categorias_database.dart';
import 'package:practica_tres/db/productos_servicios_database.dart';
import 'package:practica_tres/models/categoria.dart';
import 'package:practica_tres/models/producto_servicio.dart';

class BienesScreen extends StatefulWidget {
  const BienesScreen({super.key});

  @override
  State<BienesScreen> createState() => _BienesScreenState();
}

class _BienesScreenState extends State<BienesScreen> {
  final repo = ProductosServiciosDatabase();
  final categoriasRepo = CategoriasDatabase();
  List<ProductoServicio> productos = [];
  List<Categoria> categorias = [];

  @override
  void initState() {
    super.initState();
    cargarTodo();
  }

  Future<void> cargarTodo() async {
    final listaProductos = await repo.getAll();
    final listaCategorias = await categoriasRepo.getAll();

    setState(() {
      productos = listaProductos;
      categorias = listaCategorias;
    });
  }

  Future<void> mostrarFormulario({ProductoServicio? producto}) async {
    final nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );
    final precioController = TextEditingController(
      text: producto != null ? producto.precio.toString() : '',
    );
    int? categoriaSeleccionada =
        producto?.categoriaId ??
        (categorias.isNotEmpty ? categorias.first.id : null);

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              producto != null
                  ? 'Editar Producto/Servicio'
                  : 'Nuevo Producto/Servicio',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: precioController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<int>(
                  value: categoriaSeleccionada,
                  items: _buildCategoriasAgrupadas(),
                  onChanged: (value) => categoriaSeleccionada = value,
                  decoration: const InputDecoration(labelText: 'Categoría'),
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
                  final nombre = nombreController.text.trim();
                  final precio =
                      double.tryParse(precioController.text.trim()) ?? 0;

                  if (nombre.isEmpty || categoriaSeleccionada == null) return;

                  final nuevo = ProductoServicio(
                    id: producto?.id,
                    nombre: nombre,
                    categoriaId: categoriaSeleccionada!,
                    precio: precio,
                  );

                  if (producto == null) {
                    await repo.insert({
                      'nombre': nuevo.nombre,
                      'categoriaId': nuevo.categoriaId,
                      'precio': nuevo.precio,
                    });
                  } else {
                    await repo.update({
                      'id': nuevo.id,
                      'nombre': nuevo.nombre,
                      'categoriaId': nuevo.categoriaId,
                      'precio': nuevo.precio,
                    });
                  }
                  Navigator.pop(context);
                  cargarTodo();
                },
                child: Text(producto == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
    );
  }

  Future<void> eliminarProducto(int id) async {
    await repo.delete(id);
    cargarTodo();
  }

  String nombreCategoria(int id) {
    return categorias.firstWhere((c) => c.id == id).nombre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Productos / Servicios')),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            icon: Icon(
              Icons.add_business_rounded,
              size: 30,
              color: Colors.green,
            ),
            tooltip: 'Agregar Producto/Servicio',
            onPressed: () => mostrarFormulario(),
          ),
        ],
      ),
      body:
          productos.isEmpty
              ? Center(child: Text('No hay productos o servicios'))
              : _listaBienes(productos),
    );
  }

  Widget _listaBienes(List<ProductoServicio> bienes) {
    final productos =
        bienes.where((b) {
          final cat = categorias.firstWhere((c) => c.id == b.categoriaId);
          return cat.type == 'Producto';
        }).toList();
    final servicios =
        bienes.where((b) {
          final cat = categorias.firstWhere((c) => c.id == b.categoriaId);
          return cat.type == 'Servicio';
        }).toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (productos.isNotEmpty) ...[
          Divider(),
          Center(
            child: const Text(
              'Productos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          const SizedBox(height: 8),
          ..._buildGrupos(productos),
        ],
        if (servicios.isNotEmpty) ...[
          Divider(),
          Center(
            child: const Text(
              'Servicios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          const SizedBox(height: 8),
          ..._buildGrupos(servicios),
        ],
      ],
    );
  }

  List<Widget> _buildGrupos(List<ProductoServicio> bienes) {
    final productosPorCategoria = <String, List<ProductoServicio>>{};

    for (var prod in bienes) {
      final categoriaNombre = nombreCategoria(prod.categoriaId);
      productosPorCategoria.putIfAbsent(categoriaNombre, () => []).add(prod);
    }
    final categoriasOrdenadas =
        productosPorCategoria.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return categoriasOrdenadas.map((entry) {
      final categoria = entry.key;
      final productos = entry.value;

      productos.sort((a, b) => a.nombre.compareTo(b.nombre));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoria,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, i) {
              final prod = productos[i];
              return Card(
                elevation: 4,
                shadowColor: Colors.deepPurpleAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          prod.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Precio: \$${prod.precio.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                              size: 20,
                            ),
                            onPressed: () => mostrarFormulario(producto: prod),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              formEliminar(prod.id!);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Future<void> formEliminar(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Deseas eliminar este producto/servicio?'),
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
    if (confirm == true) {
      eliminarProducto(id);
    }
  }

  List<DropdownMenuItem<int>> _buildCategoriasAgrupadas() {
    final productos =
        categorias.where((c) => c.type == 'Producto').toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
    final servicios =
        categorias.where((c) => c.type == 'Servicio').toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));

    List<DropdownMenuItem<int>> items = [];

    if (productos.isNotEmpty) {
      items.add(
        const DropdownMenuItem<int>(
          enabled: false,
          child: Text(
            'Productos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
      );
      items.addAll(
        productos.map(
          (cat) => DropdownMenuItem(
            value: cat.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                cat.nombre,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
      );
    }

    if (servicios.isNotEmpty) {
      items.add(
        const DropdownMenuItem<int>(
          enabled: false,
          child: Text(
            'Servicios',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
        ),
      );
      items.addAll(
        servicios.map(
          (cat) => DropdownMenuItem(
            value: cat.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                cat.nombre,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }
}
