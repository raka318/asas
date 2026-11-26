import 'package:flutter/foundation.dart' show kIsWeb;

/// Kelas penyimpan seluruh konfigurasi URL dasar dan endpoint API
class ApiConstant {
  // Base URL Laravel otomatis menyesuaikan antara Web/Desktop dan Emulator Android
  static String get baseUrlLaravel {
    if (kIsWeb) {
      return 'http://192.168.101.73:8000/api';
    }
    return 'http://192.168.101.73:8000/api';
  }

  // Base URL Public API eksternal (Studio Ghibli)
  static const String publicApiUrl = 'https://ghibliapi.vercel.app';

  // Endpoint Public API
  static const String filmsEndpoint = '/films';

  // Endpoint Autentikasi Laravel Sanctum
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String userEndpoint = '/user';

  // Endpoint CRUD Tabel 1 (Kategori) & Tabel 2 (Item Koleksi)
  static const String categoriesEndpoint = '/categories';
  static const String collectionsEndpoint = '/collections';
}