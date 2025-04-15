class Categoria {
  int? id;
  String nombre;
  String type;

  Categoria({
    this.id,
    required this.nombre,
    required this.type,
  });

  factory Categoria.fromMap(Map<String, dynamic> cast) => Categoria(
        id: cast['id'],
        nombre: cast['nombre'],
        type: cast['type'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'type': type,
      };
}
