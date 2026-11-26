/// Model data untuk Public API Studio Ghibli
class FilmModel {
  final String id;
  final String title;
  final String originalTitle;
  final String image;
  final String movieBanner;
  final String description;
  final String director;
  final String producer;
  final String releaseDate;
  final String runningTime;
  final String rtScore;

  FilmModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.image,
    required this.movieBanner,
    required this.description,
    required this.director,
    required this.producer,
    required this.releaseDate,
    required this.runningTime,
    required this.rtScore,
  });

  // Mengubah JSON dari Public API Ghibli menjadi objek FilmModel
  factory FilmModel.fromJson(Map<String, dynamic> json) {
    return FilmModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Tanpa Judul',
      originalTitle: json['original_title'] ?? '',
      image: json['image'] ?? '',
      movieBanner: json['movie_banner'] ?? '',
      description: json['description'] ?? 'Tidak ada deskripsi.',
      director: json['director'] ?? '-',
      producer: json['producer'] ?? '-',
      releaseDate: json['release_date'] ?? '-',
      runningTime: json['running_time'] ?? '-',
      rtScore: json['rt_score'] ?? '-',
    );
  }
}