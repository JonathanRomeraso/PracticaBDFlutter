class VentaServicio {
  int? id;
  String titulo;
  String descripcion;
  String fecha;
  String estatus;
  int recordatorio;
  String nombreCliente;
  //String nombreVendedor;
  //double total;

  VentaServicio({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.estatus,
    required this.recordatorio,
    required this.nombreCliente,
  });

  factory VentaServicio.fromMap(Map<String, dynamic> cast) => VentaServicio(
        id: cast['id'],
        titulo: cast['titulo'],
        descripcion: cast['descripcion'],
        fecha: cast['fecha'],
        estatus: cast['estatus'],
        recordatorio: cast['recordatorio'],
        nombreCliente: cast['nombreCliente'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha,
        'estatus': estatus,
        'recordatorio': recordatorio,
        'nombreCliente': nombreCliente,
      };
}
