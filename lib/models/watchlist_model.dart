/// Model data untuk memetakan JSON watchlist yang disimpan di database Laravel.
class WatchlistModel {
  final int id;
  final int userId;
  final String filmId;
  final String title;
  final String image;
  final String director;
  final String rtScore;
  final String? personalNote;

  WatchlistModel({
    required this.id,
    required this.userId,
    required this.filmId,
    required this.title,
    required this.image,
    required this.director,
    required this.rtScore,
    this.personalNote,
  });

  /// Mengonversi respons JSON dari endpoint /api/watchlists menjadi WatchlistModel.
  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      filmId: (json['film_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      director: (json['director'] ?? '').toString(),
      rtScore: (json['rt_score'] ?? '0').toString(),
      personalNote: json['personal_note']?.toString(),
    );
  }
}
