import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('products');
  await Hive.openBox('sales'); // ✅ FIXED

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
       theme: ThemeData(
    scaffoldBackgroundColor:  Color.fromRGBO(255, 255, 255, 1), // 👈 background color
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(39, 255, 190, 0.612),
      foregroundColor: Color.fromARGB(255, 8, 8, 8),
      centerTitle: true,
    ),
  ),
  
      home: HomePage(),
    );
  }
}