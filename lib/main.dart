import 'package:flutter/material.dart';
import 'routes/app_routing.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget aplikasi dengan tema hijau sage & emerald yang nyaman di mata
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Palet warna hijau botanikal yang lembut dan tidak menyilaukan mata
    const primaryGreen = Color(0xFF2D6A4F);
    const secondaryGreen = Color(0xFF52B788);
    const softSageBg = Color(0xFFEFF6F2);

    return MaterialApp(
      title: 'Ghibli Collection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: softSageBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: secondaryGreen,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: softSageBg,
          foregroundColor: Color(0xFF1B4332),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1B4332),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFDCE8E1), width: 1),
          ),
        ),
      ),
      initialRoute: AppRouting.splash,
      onGenerateRoute: AppRouting.onGenerateRoute,
    );
  }
}