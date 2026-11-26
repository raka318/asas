import 'package:flutter/material.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';

/// Layar pembuka untuk mengecek ketersediaan token login di SharedPreferences
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Mengecek token lokal setelah jeda singkat 2 detik
  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await _authService.getToken();

    if (!mounted) return;

    // Jika token tersedia arahkan ke MainPage, jika tidak arahkan ke LoginPage
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRouting.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRouting.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter_rounded, size: 88, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Ghibli Collection',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Katalog & Koleksi Film Studio Ghibli',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}