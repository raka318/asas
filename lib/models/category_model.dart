/// Model data untuk Tabel 1 (Kategori)
class CategoryModel {
  final int id;
  final String name;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  // Mengubah JSON dari endpoint /api/categories menjadi objek CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}