import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/category_model.dart';
import '../models/collection_model.dart';
import 'auth_service.dart';

/// Layanan HTTP untuk CRUD Tabel 1 (Kategori) dan Tabel 2 (Item Koleksi)
class CrudService {
  final AuthService _authService = AuthService();

  // Mengonversi header otorisasi secara eksplisit ke Map<String, String>
  Future<dynamic> _buildHeaders() async {
    final rawHeaders = await _authService.getAuthHeaders();
    return Map<String, String>.from(rawHeaders as Map);
  }

  // =========================================================================
  // CRUD TABEL 1: KATEGORI (/api/categories)
  // =========================================================================

  // Mengambil semua data kategori milik user yang sedang login
  Future<List<CategoryModel>> getCategories() async {
    final url = Uri.parse(
      '${ApiConstant.baseUrlLaravel}${ApiConstant.categoriesEndpoint}',
    );
    final headers = await _buildHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> list = body is List ? body : (body['data'] ?? []);
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil kategori (${response.statusCode})');
  }

  // Menambah kategori baru
  Future<dynamic> createCategory(String name, String description) async {
    try {
      final url = Uri.parse(
        '${ApiConstant.baseUrlLaravel}${ApiConstant.categoriesEndpoint}',
      );
      final headers = await _buildHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return <String, dynamic>{
          'success': true,
          'message': body['message'] ?? 'Kategori berhasil ditambahkan',
        };
      }

      return <String, dynamic>{
        'success': false,
        'message':
            'Error ${response.statusCode}: ${body['message'] ?? 'Gagal menyimpan'}',
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // Mengubah data kategori berdasarkan ID
  Future<dynamic> updateCategory(
    int id,
    String name,
    String description,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConstant.baseUrlLaravel}${ApiConstant.categoriesEndpoint}/$id',
      );
      final headers = await _buildHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return <String, dynamic>{
          'success': true,
          'message': body['message'] ?? 'Kategori berhasil diperbarui',
        };
      }

      return <String, dynamic>{
        'success': false,
        'message':
            'Error ${response.statusCode}: ${body['message'] ?? 'Gagal memperbarui'}',
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // Menghapus kategori berdasarkan ID
  Future<bool> deleteCategory(int id) async {
    final url = Uri.parse(
      '${ApiConstant.baseUrlLaravel}${ApiConstant.categoriesEndpoint}/$id',
    );
    final headers = await _buildHeaders();
    final response = await http.delete(url, headers: headers);
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // =========================================================================
  // CRUD TABEL 2: ITEM KOLEKSI (/api/collections)
  // =========================================================================

  // Mengambil daftar item koleksi milik user (opsional filter berdasarkan categoryId)
  Future<List<CollectionModel>> getCollections({int? categoryId}) async {
    String endpoint =
        '${ApiConstant.baseUrlLaravel}${ApiConstant.collectionsEndpoint}';
    if (categoryId != null) {
      endpoint += '?category_id=$categoryId';
    }

    final url = Uri.parse(endpoint);
    final headers = await _buildHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> list = body is List ? body : (body['data'] ?? []);
      return list.map((e) => CollectionModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil koleksi (${response.statusCode})');
  }

  // Menambah item koleksi baru dengan relasi category_id
  Future<dynamic> createCollection({
    required int categoryId,
    required String title,
    String? note,
    String? rating,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstant.baseUrlLaravel}${ApiConstant.collectionsEndpoint}',
      );
      final headers = await _buildHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'category_id': categoryId,
          'title': title,
          'note': note,
          'rating': rating,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return <String, dynamic>{
          'success': true,
          'message': body['message'] ?? 'Item koleksi ditambahkan',
        };
      }

      return <String, dynamic>{
        'success': false,
        'message':
            'Error ${response.statusCode}: ${body['message'] ?? 'Gagal menyimpan'}',
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // Mengubah item koleksi berdasarkan ID
  Future<dynamic> updateCollection({
    required int id,
    required int categoryId,
    required String title,
    String? note,
    String? rating,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstant.baseUrlLaravel}${ApiConstant.collectionsEndpoint}/$id',
      );
      final headers = await _buildHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'category_id': categoryId,
          'title': title,
          'note': note,
          'rating': rating,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return <String, dynamic>{
          'success': true,
          'message': body['message'] ?? 'Item koleksi diperbarui',
        };
      }

      return <String, dynamic>{
        'success': false,
        'message':
            'Error ${response.statusCode}: ${body['message'] ?? 'Gagal memperbarui'}',
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // Menghapus item koleksi berdasarkan ID
  Future<bool> deleteCollection(int id) async {
    final url = Uri.parse(
      '${ApiConstant.baseUrlLaravel}${ApiConstant.collectionsEndpoint}/$id',
    );
    final headers = await _buildHeaders();
    final response = await http.delete(url, headers: headers);
    return response.statusCode == 200 || response.statusCode == 204;
  }
}