import 'package:flutter/material.dart';
import 'package:practica_tres/models/categoria.dart';
import 'package:practica_tres/models/producto_servicio.dart';

class DetalleForm extends StatelessWidget {
  final List<Categoria> categorias;
  final List<ProductoServicio> productosFiltrados;
  final int? categoriaSeleccionadaId;
  final ProductoServicio? productoSeleccionado;
  final String tipoDescuento;
  final List<String> tiposDescuento;
  final TextEditingController cantidadController;
  final TextEditingController precioController;
  final TextEditingController descuentoController;
  final VoidCallback onGuardar;
  final VoidCallback? onCancelarEdicion;
  final Function(int?) onCategoriaChanged;
  final Function(ProductoServicio?) onProductoChanged;
  final Function(String?) onTipoDescuentoChanged;

  const DetalleForm({
    super.key,
    required this.categorias,
    required this.productosFiltrados,
    required this.categoriaSeleccionadaId,
    required this.productoSeleccionado,
    required this.tipoDescuento,
    required this.tiposDescuento,
    required this.cantidadController,
    required this.precioController,
    required this.descuentoController,
    required this.onGuardar,
    this.onCancelarEdicion,
    required this.onCategoriaChanged,
    required this.onProductoChanged,
    required this.onTipoDescuentoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Agregar producto o servicio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: categoriaSeleccionadaId,
            items:
                categorias.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.nombre),
                  );
                }).toList(),
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            onChanged: onCategoriaChanged,
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<ProductoServicio>(
            value: productoSeleccionado,
            items:
                productosFiltrados.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.nombre));
                }).toList(),
            decoration: InputDecoration(
              labelText: 'Producto',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.shopping_bag_outlined),
            ),
            onChanged: onProductoChanged,
          ),
          SizedBox(height: 12),
          TextField(
            controller: cantidadController,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.format_list_numbered),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            controller: precioController,
            decoration: InputDecoration(
              labelText: 'Precio unitario',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            enabled: false,
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: tipoDescuento,
            decoration: InputDecoration(
              labelText: 'Tipo de descuento por unidad',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.percent),
            ),
            items:
                tiposDescuento.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
            onChanged: onTipoDescuentoChanged,
          ),
          SizedBox(height: 12),
          TextField(
            controller: descuentoController,
            decoration: InputDecoration(
              labelText: 'Descuento por unidad',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.local_offer_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.save, color: Colors.white, size: 20),
              label: Text(
                'Guardar detalle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onGuardar,
            ),
          ),
          if (onCancelarEdicion != null) ...[
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onCancelarEdicion,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.cancel, color: Colors.grey[700], size: 20),
                label: Text(
                  'Cancelar edición',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
