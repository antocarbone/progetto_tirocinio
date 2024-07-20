import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.orangeAccent,
      ),
      home: HomePage()
      //home: LoginPage(),
    );
  }
}