class Categoria {
  int? id;
  String nombre;

  Categoria({
    this.id,
    required this.nombre,
  });

  factory Categoria.fromMap(Map<String, dynamic> cast) => Categoria(
        id: cast['id'],
        nombre: cast['nombre'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
      };
}
