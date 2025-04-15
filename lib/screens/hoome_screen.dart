//import 'package:dark_light_button/dark_light_button.dart';

import 'package:flutter/material.dart';

class HoomeScreen extends StatefulWidget {
  const HoomeScreen({super.key});

  @override
  State<HoomeScreen> createState() => _HoomeScreenState();
}

class _HoomeScreenState extends State<HoomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Productos y Servicios")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://www.w3schools.com/howto/img_avatar.png",
                ),
              ),
              accountName: Text("Nombre de Usuario"),
              accountEmail: Text("Correo de Usuario"),
            ),
            ListTile(
              leading: Icon(Icons.storage),
              title: Text("Categorías"),
              subtitle: Text("Ver y editar categorías"),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/categorias");
                },
                child: Icon(Icons.chevron_right),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.shopping_cart_rounded),
              title: Text("Bienes y Servicios"),
              subtitle: Text("Ver y editar bienes y servicios"),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/bienes");
                },
                child: Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bienvenido a la App de Productos y Servicios",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/ventasServicios");
              },
              child: Text("Ir a Ventas y Servicios"),
            ),
          ],
        ),
      ),
    );
  }
}
