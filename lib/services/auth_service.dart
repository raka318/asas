import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constant.dart';
import '../models/user_model.dart';

/// Layanan HTTP untuk autentikasi dan manajemen token Laravel Sanctum
class AuthService {
  static const String _tokenKey = 'auth_token';

  // Mengambil token yang tersimpan di penyimpanan lokal
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Menyimpan token ke penyimpanan lokal
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Menghapus token saat logout
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Header standar JSON lengkap dengan Bearer Token jika tersedia
  Future<dynamic> getAuthHeaders() async {
    final token = await getToken();
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Proses Register akun baru ke Laravel
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse(
      '${ApiConstant.baseUrlLaravel}${ApiConstant.registerEndpoint}',
    );
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Simpan token jika API langsung mengembalikan access_token atau token
      final token =
          body['access_token'] ?? body['token'] ?? body['data']?['token'];
      if (token != null) {
        await saveToken(token);
      }
      return <String, dynamic>{
        'success': true,
        'message': body['message'] ?? 'Registrasi berhasil',
      };
    }

    return <String, dynamic>{
      'success': false,
      'message':
          body['message'] ?? 'Registrasi gagal, periksa kembali data Anda',
    };
  }

  // Proses Login user ke Laravel Sanctum
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiConstant.baseUrlLaravel}${ApiConstant.loginEndpoint}',
    );
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final token =
          body['access_token'] ?? body['token'] ?? body['data']?['token'];
      if (token != null) {
        await saveToken(token);
        return <String, dynamic>{
          'success': true,
          'message': 'Login berhasil',
        };
      }
      return <String, dynamic>{
        'success': false,
        'message': 'Token tidak ditemukan pada respons server',
      };
    }

    return <String, dynamic>{
      'success': false,
      'message': body['message'] ?? 'Email atau password salah',
    };
  }

  // Mengambil data user yang sedang login dari endpoint /api/user
  Future<UserModel?> getCurrentUser() async {
    final url = Uri.parse(
      '${ApiConstant.baseUrlLaravel}${ApiConstant.userEndpoint}',
    );
    final headers = await getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final userData =
          body is Map<String, dynamic> && body.containsKey('data')
              ? body['data']
              : body;
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // Proses Logout dari server dan hapus token lokal
  Future<void> logout() async {
    try {
      final url = Uri.parse(
        '${ApiConstant.baseUrlLaravel}${ApiConstant.logoutEndpoint}',
      );
      final headers = await getAuthHeaders();
      await http.post(url, headers: headers);
    } catch (_) {
      // Abaikan error jaringan saat logout agar token lokal tetap terhapus
    } finally {
      await removeToken();
    }
  }
}