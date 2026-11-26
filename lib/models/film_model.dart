/// Model data untuk memetakan JSON film dari Public API Studio Ghibli.
class FilmModel {
  final String id;
  final String title;
  final String originalTitle;
  final String originalTitleRomanised;
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
    required this.originalTitleRomanised,
    required this.image,
    required this.movieBanner,
    required this.description,
    required this.director,
    required this.producer,
    required this.releaseDate,
    required this.runningTime,
    required this.rtScore,
  });

  /// Mengonversi objek Map JSON menjadi instance FilmModel dengan tipe data aman.
  factory FilmModel.fromJson(Map<String, dynamic> json) {
    return FilmModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Tanpa Judul').toString(),
      originalTitle: (json['original_title'] ?? '').toString(),
      originalTitleRomanised: (json['original_title_romanised'] ?? '')
          .toString(),
      image: (json['image'] ?? '').toString(),
      movieBanner: (json['movie_banner'] ?? '').toString(),
      description: (json['description'] ?? 'Tidak ada sinopsis.').toString(),
      director: (json['director'] ?? '-').toString(),
      producer: (json['producer'] ?? '-').toString(),
      // Konversi paksa ke String agar aman jika API mengirim angka atau teks
      releaseDate: (json['release_date'] ?? '-').toString(),
      runningTime: (json['running_time'] ?? '-').toString(),
      rtScore: (json['rt_score'] ?? '0').toString(),
    );
  }
}
