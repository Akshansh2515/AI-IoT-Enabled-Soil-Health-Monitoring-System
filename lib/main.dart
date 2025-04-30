import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const SoilHealthApp());
}

class SoilHealthApp extends StatelessWidget {
  const SoilHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soil Health Monitor',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue[700],
        scaffoldBackgroundColor:
            Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            color: Colors.black87,
          ),
          bodyMedium: const TextStyle(
            color: Colors.black54,
          ),
          headlineSmall: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Colors.green[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green[300],
          textTheme: ButtonTextTheme.primary,
        ),
        cardTheme: CardTheme(
          color: Colors.blue[50],
        ),
      ),
      home: const HomePage(),
    );
  }
}
