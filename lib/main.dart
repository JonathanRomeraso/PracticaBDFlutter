import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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
        home: GestureDetector(
      onTap: () {
        contador++;
        print(contador);
        setState(() {});
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffb74093),
          title: Center(
            child: Text(
              'HOla MUndO :)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Swar',
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Image.network(
                'https://i0.wp.com/celaya.tecnm.mx/wp-content/uploads/2021/11/LOGO-LINCE-ITC-01.png'),
            //child: Icon(Icons.plus_one_rounded),
            //child: Center(child: Text('+', style: TextStyle(fontSize: 30),)),
            onPressed: () {
              contador++;
              print(contador);
              setState(() {});
            }),
        body: Center(
          child: Text(
            'Valor del Contador $contador',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    ));
  }
}
