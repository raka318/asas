import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asas/config/api_config.dart';

typedef JsonResponse = Map<String, dynamic>;

/// Service untuk menangani autentikasi pengguna (Login, Register, Logout, Cek Token).
class AuthService {
  static const String _tokenKey = 'token';
  static const String _userNameKey = 'user_name';

  /// Menyimpan token dan nama user ke penyimpanan lokal perangkat.
  Future<void> _saveSession(String token, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userNameKey, userName);
  }

  /// Mengambil token autentikasi yang tersimpan.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Mengambil nama pengguna yang sedang login.
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Pengguna Ghibli';
  }

  /// Memeriksa apakah user sudah memiliki token login.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Mengekstrak token dari berbagai kemungkinan struktur JSON Laravel.
  String? _extractToken(dynamic data) {
    if (data is! Map) return null;
    if (data['access_token'] != null) return data['access_token'].toString();
    if (data['token'] != null) return data['token'].toString();
    if (data['data'] is Map) {
      if (data['data']['access_token'] != null) {
        return data['data']['access_token'].toString();
      }
      if (data['data']['token'] != null) {
        return data['data']['token'].toString();
      }
    }
    return null;
  }

  /// Mengekstrak nama user dari berbagai kemungkinan struktur JSON Laravel.
  String _extractUserName(dynamic data, String fallback) {
    if (data is! Map) return fallback;
    if (data['user'] is Map && data['user']['name'] != null) {
      return data['user']['name'].toString();
    }
    if (data['data'] is Map) {
      if (data['data']['user'] is Map && data['data']['user']['name'] != null) {
        return data['data']['user']['name'].toString();
      }
      if (data['data']['name'] != null) {
        return data['data']['name'].toString();
      }
    }
    return fallback;
  }

  /// Mengirim permintaan registrasi akun baru ke backend Laravel.
  Future<JsonResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.laravelBaseUrl}/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          // Sertakan password_confirmation jaga-jaga jika AuthController lama pakai rule 'confirmed'
          'password_confirmation': password,
        }),
      );

      final data = jsonDecode(response.body);
      final token = _extractToken(data);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          token != null &&
          token.isNotEmpty) {
        final userName = _extractUserName(data, name);
        await _saveSession(token, userName);
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      }

      String errorMessage =
          data['message'] ?? 'Registrasi gagal atau token tidak ditemukan';
      if (data['errors'] != null && data['errors'] is Map) {
        final firstErrorList = (data['errors'] as Map).values.first;
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          errorMessage = firstErrorList.first.toString();
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server Laravel: $e',
      };
    }
  }

  /// Mengirim permintaan login ke backend Laravel dan menyimpan token.
  Future<JsonResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.laravelBaseUrl}/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      final token = _extractToken(data);

      if (response.statusCode == 200 && token != null && token.isNotEmpty) {
        final userName = _extractUserName(data, 'User');
        await _saveSession(token, userName);
        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Email atau password salah',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server Laravel: $e',
      };
    }
  }

  /// Menghapus token di server Laravel dan membersihkan sesi lokal.
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse('${ApiConfig.laravelBaseUrl}/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {
      // Tetap lanjutkan hapus sesi lokal meskipun server tidak merespons
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userNameKey);
    }
  }
}
