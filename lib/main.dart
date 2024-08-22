import 'package:dashboard_tirocinio/presentation/theme.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_tirocinio/default_initialize.dart'
  if (dart.library.html) 'package:dashboard_tirocinio/web_initialize.dart';

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

    TextTheme textTheme = createTextTheme(context, "ABeeZee", "ABeeZee");
    MaterialTheme theme = MaterialTheme(textTheme);

    UrlInitImpl initializer = UrlInitImpl();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.lightHighContrast(),
      home: initializer.initUrl(),
    );
  }
}
