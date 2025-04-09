import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class ConnectionDatabase {
  static const nameDB = 'VetasServicio';
  static const versionDB = 1;

  //static final ConnectionDatabase _instance = ConnectionDatabase._internal();
  //factory ConnectionDatabase() => _instance;
  //ConnectionDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, nameDB);

    return await openDatabase(
      path,
      version: versionDB,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE VentasServicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo VARCHAR(50),
        descripcion VARCHAR(100),
        fecha VARCHAR(10),
        estatus VARCHAR(10),
        recordatorio INTEGER, 
        nombreCliente VARCHAR(150),
      )
    ''');
    await db.execute('''
      CREATE TABLE Categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(50),
      )
    ''');

    await db.execute('''
      CREATE TABLE ProductosServicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT ,
        categoriaId INTEGER ,
        precio REAL,
        FOREIGN KEY (categoriaId) REFERENCES Categorias (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE DetalleVentaServicio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ventaServicioId INTEGER ,
        productoServicioId INTEGER ,
        cantidad INTEGER ,
        descuento REAL ,
        subtotal REAL ,
        FOREIGN KEY (ventaServicioId) REFERENCES VentasServicios (id),
        FOREIGN KEY (productoServicioId) REFERENCES ProductosServicios (id)
      )
    ''');
  }
}
