import 'category_model.dart';

/// Model data untuk Tabel 2 (Item Koleksi milik user)
class CollectionModel {
  final int id;
  final int categoryId;
  final String title;
  final String? note;
  final String? rating;
  final CategoryModel? category;

  CollectionModel({
    required this.id,
    required this.categoryId,
    required this.title,
    this.note,
    this.rating,
    this.category,
  });

  // Mengubah JSON dari endpoint /api/collections menjadi objek CollectionModel
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
      title: json['title'] ?? '',
      note: json['note'],
      rating: json['rating']?.toString(),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
    );
  }
}