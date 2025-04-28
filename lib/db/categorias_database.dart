import 'package:practica_tres/db/connection/connection_database.dart';
import 'package:practica_tres/models/categoria.dart';

class CategoriasDatabase {
  final db = ConnectionDatabase();

  Future<int> insert(Map<String, dynamic> categoria) async {
    final con = await db.database;
    return await con.insert('Categorias', categoria);
  }

  Future<List<Categoria>> getAll() async {
    final con = await db.database;
    final res = await con.query('Categorias');
    return res.map((categoria) => Categoria.fromMap(categoria)).toList();
  }

  Future<int> update(Map<String, dynamic> categoria) async {
    final con = await db.database;
    return await con.update(
      'Categorias',
      categoria,
      where: 'id = ?',
      whereArgs: [categoria['id']],
    );
  }

  Future<int> delete(int id) async {
    final con = await db.database;
    return await con.delete('Categorias', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> puedeEliminarCategoria(int categoriaId) async {
    final con = await db.database;
    final result = await con.query(
      'ProductosServicios',
      where: 'categoriaId = ?',
      whereArgs: [categoriaId],
    );
    return result.isEmpty;
  }

}
