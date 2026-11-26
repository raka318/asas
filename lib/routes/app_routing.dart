import 'package:flutter/material.dart';
import '../models/film_model.dart';
import '../screens/splash_screen.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/main_page.dart';
import '../screens/explore_page.dart';
import '../screens/explore_detail_page.dart';
import '../screens/collection_page.dart';
import '../screens/profile_about_page.dart';

/// Kelas manajemen seluruh Named Routes aplikasi
class AppRouting {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String explore = '/explore';
  static const String exploreDetail = '/explore-detail';
  static const String collection = '/collection';
  static const String profileAbout = '/profile-about';

  /// Generator rute dinamis yang dihubungkan ke MaterialApp
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case main:
        return MaterialPageRoute(builder: (_) => const MainPage());

      case explore:
        return MaterialPageRoute(builder: (_) => const ExplorePage());

      case exploreDetail:
        // Mengambil data objek FilmModel yang dikirim dari ExplorePage
        final film = settings.arguments as FilmModel;
        return MaterialPageRoute(
          builder: (_) => ExploreDetailPage(film: film),
        );

      case collection:
        return MaterialPageRoute(builder: (_) => const CollectionPage());

      case profileAbout:
        return MaterialPageRoute(builder: (_) => const ProfileAboutPage());

      default:
        // Halaman fallback jika rute tidak ditemukan
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Halaman ${settings.name} tidak ditemukan'),
            ),
          ),
        );
    }
  }
}