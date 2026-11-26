import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asas/config/api_config.dart';
import 'package:asas/models/film_model.dart';
import 'package:asas/models/watchlist_model.dart';
import 'package:asas/services/auth_service.dart';

/// Alias tipe data untuk mencegah pemotongan karakter generik saat disalin.
typedef HeaderMap = Map<String, String>;
typedef ApiResult = Map<String, dynamic>;

/// Service untuk melakukan operasi CRUD Watchlist ke backend Laravel.
class WatchlistService {
  final AuthService _authService = AuthService();

  /// Membuat header HTTP standar lengkap dengan Bearer Token Sanctum.
  Future<HeaderMap> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  /// Mengambil semua daftar watchlist milik user yang sedang login (GET /api/watchlists).
  Future<List<WatchlistModel>> getWatchlists() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.laravelBaseUrl}/watchlists'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? [];
        return dataList.map((item) => WatchlistModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Gagal mengambil watchlist (Kode: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan saat memuat watchlist: $e');
    }
  }

  /// Menyimpan film Ghibli ke database Laravel (POST /api/watchlists).
  Future<ApiResult> addToWatchlist(
    FilmModel film, {
    String? personalNote,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.laravelBaseUrl}/watchlists'),
        headers: headers,
        body: jsonEncode({
          'film_id': film.id,
          'title': film.title,
          'image': film.image,
          'director': film.director,
          'rt_score': film.rtScore,
          'personal_note': personalNote,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Berhasil disimpan ke Watchlist',
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal menambahkan ke Watchlist',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// Memperbarui catatan pribadi film di watchlist (PUT /api/watchlists/{id}).
  Future<ApiResult> updateNote(int id, String personalNote) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.laravelBaseUrl}/watchlists/$id'),
        headers: headers,
        body: jsonEncode({'personal_note': personalNote}),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Catatan berhasil diperbarui',
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal memperbarui catatan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// Menghapus film dari daftar watchlist (DELETE /api/watchlists/{id}).
  Future<ApiResult> deleteWatchlist(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.laravelBaseUrl}/watchlists/$id'),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Film dihapus dari Watchlist',
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal menghapus film',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}
