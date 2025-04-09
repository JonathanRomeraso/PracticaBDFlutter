class DetalleVentaServicio {
  int? id;
  int ventaServicioId;
  int productoServicioId;
  int cantidad;
  double descuento;
  double subtotal;

  DetalleVentaServicio({
    this.id,
    required this.ventaServicioId,
    required this.productoServicioId,
    required this.cantidad,
    required this.descuento,
    required this.subtotal,
  });

  factory DetalleVentaServicio.fromMap(Map<String, dynamic> cast) => DetalleVentaServicio(
        id: cast['id'],
        ventaServicioId: cast['ventaServicioId'],
        productoServicioId: cast['productoServicioId'],
        cantidad: cast['cantidad'],
        descuento: cast['descuento'],
        subtotal: cast['subtotal'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'ventaServicioId': ventaServicioId,
        'productoServicioId': productoServicioId,
        'cantidad': cantidad,
        'descuento': descuento,
        'subtotal': subtotal,
      };
}
