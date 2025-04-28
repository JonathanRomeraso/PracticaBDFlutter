import 'package:practica_tres/db/connection/connection_database.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class VentaServicioDatabase {
  final db = ConnectionDatabase();

  Future<int> insert(Map<String, dynamic> venta) async {
    final con = await db.database;
    return await con.insert('VentasServicios', venta);
  }

  Future<List<VentaServicio>> select() async {
    final con = await db.database;
    final res = await con.query('VentasServicios');
    return res
        .map((ventaServicio) => VentaServicio.fromMap(ventaServicio))
        .toList();
  }

  Future<int> update(Map<String, dynamic> venta) async {
    final con = await db.database;
    return await con.update(
      'VentasServicios',
      venta,
      where: 'id = ?',
      whereArgs: [venta['id']],
    );
  }

  Future<int> delete(int id) async {
    final con = await db.database;
    await con.delete(
      'DetalleVentaServicio',
      where: 'ventaServicioId = ?',
      whereArgs: [id],
    );
    return await con.delete(
      'VentasServicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
