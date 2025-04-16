import 'package:practica_tres/db/connection/connection_database.dart';
import 'package:practica_tres/models/detalle_venta_servicio.dart';
import 'package:practica_tres/models/ventas_servicio.dart';

class DetalleVentaServicioDatabase {
  final db = ConnectionDatabase();

  Future<int> insert(Map<String, dynamic> detalle) async {
    final con = await db.database;
    return await con.insert('DetalleVentaServicio', detalle);
  }

  Future<List<DetalleVentaServicio>> getAll() async {
    final con = await db.database;

    final res = await con.query('DetalleVentaServicio');
    return res
        .map(
          (detalleVentaServicio) =>
              DetalleVentaServicio.fromMap(detalleVentaServicio),
        )
        .toList();
  }

  Future<int> update(Map<String, dynamic> detalle) async {
    final con = await db.database;

    return await con.update(
      'DetalleVentaServicio',
      detalle,
      where: 'id = ?',
      whereArgs: [detalle['id']],
    );
  }

  Future<int> delete(int id) async {
    final con = await db.database;

    return await con.delete(
      'DetalleVentaServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DetalleVentaServicio>> getByVentaId(int ventaId) async {
    final con = await db.database;
    final maps = await con.query(
      'DetalleVentaServicio',
      where: 'ventaServicioId = ?',
      whereArgs: [ventaId],
    );

    return maps.map((map) => DetalleVentaServicio.fromMap(map)).toList();
  }
}
