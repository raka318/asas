import 'package:flutter/material.dart';
import 'package:asas/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget aplikasi Studio Ghibli (asas).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio Ghibli Watchlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
