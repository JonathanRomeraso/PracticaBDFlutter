import 'package:flutter/material.dart';
import 'package:practica_tres/screens/bienes_screen.dart';
import 'package:practica_tres/screens/categorias_screen.dart';
//import 'package:practica_tres/screens/detalle_venta_screen.dart';
import 'package:practica_tres/screens/first_screen.dart';
import 'package:practica_tres/screens/hoome_screen.dart';
import 'package:practica_tres/screens/ventas_servicios_screen.dart';
import 'package:practica_tres/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  await initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int contador = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/ventasServicios": (context) => VentasServiciosScreen(),
        "/categorias": (context) => CategoriasScreen(),
        "/bienes": (context) => BienesScreen(),
        //"/detalle": (context) => DetalleVentaScreen(),
        "/home": (context) => HoomeScreen(),
      },
      //theme: ThemeData.dark(),
      // theme: ThemeSettings.purpleDarkTheme(),
      title: 'Productos y Servicios',
      home: FirstScreen(),
    );
  }
}
