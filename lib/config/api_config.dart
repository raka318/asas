import 'package:flutter/foundation.dart';

/// Konfigurasi alamat URL dasar untuk Public API Ghibli dan Backend Laravel.
class ApiConfig {
  // Base URL untuk mengambil daftar katalog film Studio Ghibli
  static const String ghibliBaseUrl = 'https://ghibliapi.vercel.app';

  // Base URL untuk backend Laravel (api_flutter)
  // Otomatis menyesuaikan antara Flutter Web/Desktop dan Emulator Android
  static String get laravelBaseUrl {
    if (kIsWeb) {
      return 'http://10.10.8.107:8000/api';
    }
    // Gunakan 10.0.2.2 untuk Emulator Android.
    // Jika memakai HP fisik via Wi-Fi, ganti dengan IP laptop (misal: http://192.168.1.10:8000/api)
    return 'http://10.10.8.107:8000/api';
  }
}
