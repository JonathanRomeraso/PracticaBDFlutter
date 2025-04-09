class ProductoServicio {
  int? id;
  String nombre;
  int categoriaId;
  double precio;

  ProductoServicio({
    this.id,
    required this.nombre,
    required this.categoriaId,
    required this.precio,
  });

  factory ProductoServicio.fromMap(Map<String, dynamic> cast) => ProductoServicio(
        id: cast['id'],
        nombre: cast['nombre'],
        categoriaId: cast['categoriaId'],
        precio: cast['precio'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'categoriaId': categoriaId,
        'precio': precio,
      };
}
