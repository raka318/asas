import 'package:flutter/material.dart';
import 'package:asas/models/film_model.dart';
import 'package:asas/services/watchlist_service.dart';

/// Halaman detail informasi film Ghibli serta tombol simpan ke Watchlist Laravel.
class DetailFilmPage extends StatefulWidget {
  final FilmModel film;

  const DetailFilmPage({super.key, required this.film});

  @override
  State<DetailFilmPage> createState() => _DetailFilmPageState();
}

class _DetailFilmPageState extends State<DetailFilmPage> {
  final WatchlistService _watchlistService = WatchlistService();
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Menampilkan dialog opsional untuk menambahkan catatan sebelum simpan ke Watchlist.
  Future<void> _showAddDialog() async {
    _noteController.clear();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah ke Watchlist'),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Catatan Pribadi (Opsional)',
            hintText: 'Contoh: Mau ditonton akhir pekan ini...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    final result = await _watchlistService.addToWatchlist(
      widget.film,
      personalNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? ''),
        backgroundColor: result['success'] == true
            ? Colors.teal.shade700
            : Colors.orange.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final film = widget.film;

    return Scaffold(
      appBar: AppBar(
        title: Text(film.title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar banner lebar (landscape) di bagian atas
            Image.network(
              film.movieBanner,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 210,
                color: Colors.grey.shade300,
                child: const Center(child: Icon(Icons.movie, size: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          film.image,
                          width: 105,
                          height: 155,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 105,
                            height: 155,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              film.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${film.originalTitle} (${film.originalTitleRomanised})',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Sutradara: ${film.director}'),
                            Text('Produser: ${film.producer}'),
                            Text(
                              'Rilis: ${film.releaseDate} • ${film.runningTime} mnt',
                            ),
                            const SizedBox(height: 6),
                            Chip(
                              label: Text('Skor RT: ${film.rtScore}%'),
                              backgroundColor: Colors.teal.shade50,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sinopsis',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    film.description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _showAddDialog,
                      icon: const Icon(Icons.bookmark_add),
                      label: Text(
                        _isSaving ? 'Menyimpan...' : 'Tambah ke Watchlist',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
