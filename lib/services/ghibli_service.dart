import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asas/config/api_config.dart';
import 'package:asas/models/film_model.dart';

/// Service untuk mengambil katalog film langsung dari Public API Studio Ghibli.
class GhibliService {
  /// Mengambil seluruh daftar film dari endpoint /films.
  Future<List<FilmModel>> getAllFilms() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.ghibliBaseUrl}/films'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => FilmModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat katalog Ghibli (Kode: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data film: $e');
    }
  }
}
