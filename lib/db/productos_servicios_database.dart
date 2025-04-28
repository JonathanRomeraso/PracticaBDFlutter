import 'package:practica_tres/db/connection/connection_database.dart';
import 'package:practica_tres/models/producto_servicio.dart';

class ProductosServiciosDatabase {
  final db = ConnectionDatabase();

  Future<int> insert(Map<String, dynamic> producto) async {
    final con = await db.database;
    return await con.insert('ProductosServicios', producto);
  }

  Future<List<ProductoServicio>> getAll() async {
    final con = await db.database;
    final res = await con.query('ProductosServicios');
    return res
        .map((productoServicio) => ProductoServicio.fromMap(productoServicio))
        .toList();
  }

  Future<int> update(Map<String, dynamic> producto) async {
    final con = await db.database;
    return await con.update(
      'ProductosServicios',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  Future<int> delete(int id) async {
    final con = await db.database;
    return await con.delete(
      'ProductosServicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> puedeEliminarProducto(int productoId) async {
    final con = await db.database;
    final result = await con.query(
      'DetalleVentaServicio',
      where: 'productoServicioId = ?',
      whereArgs: [productoId],
    );
    return result.isEmpty;
  }
}
