import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/film_model.dart';

/// Layanan HTTP untuk mengambil data dari Public API eksternal
class PublicApiService {
  // Mengambil daftar seluruh film dari Public API Studio Ghibli
  Future<List<FilmModel>> fetchFilms() async {
    final url = Uri.parse('${ApiConstant.publicApiUrl}${ApiConstant.filmsEndpoint}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FilmModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data film (Kode: ${response.statusCode})');
    }
  }
}