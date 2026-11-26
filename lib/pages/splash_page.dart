import 'package:flutter/material.dart';
import 'package:asas/services/auth_service.dart';
import 'package:asas/pages/login_page.dart';
import 'package:asas/pages/main_navigation.dart';

/// Halaman awal untuk memeriksa status login pengguna melalui SharedPreferences.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Memeriksa ketersediaan token dan mengarahkan ke halaman yang sesuai.
  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final loggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const MainNavigation() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter_rounded, size: 72, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Studio Ghibli Catalog',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
