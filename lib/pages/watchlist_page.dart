import 'package:flutter/material.dart';
import 'package:asas/models/watchlist_model.dart';
import 'package:asas/services/watchlist_service.dart';

/// Halaman daftar film Watchlist dari MySQL Laravel (Read, Update catatan, Delete).
class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final WatchlistService _watchlistService = WatchlistService();

  List<WatchlistModel> _watchlists = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWatchlists();
  }

  /// Mengambil daftar watchlist terbaru dari backend Laravel.
  Future<void> _loadWatchlists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _watchlistService.getWatchlists();
      if (!mounted) return;
      setState(() {
        _watchlists = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Menampilkan dialog untuk mengubah catatan pribadi (PUT /api/watchlists/{id}).
  Future<void> _showEditDialog(WatchlistModel item) async {
    final controller = TextEditingController(text: item.personalNote ?? '');

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Catatan: ${item.title}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Catatan Pribadi',
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

    if (saved != true) return;

    final result = await _watchlistService.updateNote(
      item.id,
      controller.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'] ?? '')));

    if (result['success'] == true) {
      _loadWatchlists();
    }
  }

  /// Menghapus item dari watchlist setelah konfirmasi (DELETE /api/watchlists/{id}).
  Future<void> _confirmDelete(WatchlistModel item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dari Watchlist?'),
        content: Text('Yakin ingin menghapus "${item.title}" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _watchlistService.deleteWatchlist(item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'] ?? '')));

    if (result['success'] == true) {
      _loadWatchlists();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadWatchlists,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    if (_watchlists.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadWatchlists,
        child: ListView(
          children: const [
            SizedBox(height: 160),
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Center(
              child: Text(
                'Watchlist masih kosong.\nTambahkan film dari Katalog Ghibli!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlists,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _watchlists.length,
        itemBuilder: (context, index) {
          final item = _watchlists[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.image,
                  width: 55,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.movie, size: 40),
                ),
              ),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.director} • ★ ${item.rtScore}%'),
                  const SizedBox(height: 4),
                  Text(
                    (item.personalNote != null && item.personalNote!.isNotEmpty)
                        ? 'Catatan: ${item.personalNote}'
                        : 'Belum ada catatan pribadi',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Catatan',
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed: () => _showEditDialog(item),
                  ),
                  IconButton(
                    tooltip: 'Hapus',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
