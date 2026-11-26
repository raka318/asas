import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/film_model.dart';
import '../services/crud_service.dart';

/// Halaman detail film dengan header banner imersif, tombol kaca, dan fitur simpan cepat ke Koleksi
class ExploreDetailPage extends StatefulWidget {
  final FilmModel film;

  const ExploreDetailPage({super.key, required this.film});

  @override
  State<ExploreDetailPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreDetailPage> {
  final CrudService _crudService = CrudService();
  bool _isSaving = false;

  // Membuka dialog pilih kategori untuk menyimpan film dari Explore ke Koleksi Laravel
  Future<void> _openSaveToCollectionDialog() async {
    setState(() => _isSaving = true);
    try {
      final categories = await _crudService.getCategories();
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Kategori masih kosong! Buat kategori dulu di tab Koleksi.',
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      int selectedCategoryId = categories.first.id;
      final ratingController = TextEditingController();
      final noteController = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Simpan ke Koleksi',
              style: TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan judul film yang dipilih secara otomatis
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.film.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dropdown kategori dari Tabel 1 Laravel
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Pilih Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCategoryId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ratingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Rating Pribadi (1 - 10, Opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan Singkat (Opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Color(0xFF52796F)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await _crudService.createCollection(
                    categoryId: selectedCategoryId,
                    title: widget.film.title,
                    note: noteController.text.trim(),
                    rating: ratingController.text.trim(),
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '"${widget.film.title}" disimpan ke Koleksi!'
                            : 'Gagal menyimpan film ke koleksi',
                      ),
                      backgroundColor: success
                          ? const Color(0xFF2D6A4F)
                          : Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final film = widget.film;
    const softSageBg = Color(0xFFEFF6F2);
    const darkGreen = Color(0xFF1B4332);
    const primaryGreen = Color(0xFF2D6A4F);

    return Scaffold(
      backgroundColor: softSageBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian atas: Banner besar + gradasi menyatu ke background + tombol back kaca
            Stack(
              children: [
                SizedBox(
                  height: 290,
                  width: double.infinity,
                  child: Image.network(
                    film.movieBanner.isNotEmpty
                        ? film.movieBanner
                        : film.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFD8F3DC),
                      child: const Center(
                        child: Icon(
                          Icons.movie_rounded,
                          size: 64,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ),

                // Gradasi lembut di bagian bawah banner agar menyatu dengan latar sage
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.35, 1.0],
                        colors: [
                          Colors.transparent,
                          softSageBg,
                        ],
                      ),
                    ),
                  ),
                ),

                // Tombol kembali melayang dengan efek kaca buram (iOS Glass)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bagian Poster + Judul Utama + Judul Jepang
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      film.image,
                      width: 105,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 105,
                        height: 150,
                        color: const Color(0xFFD8F3DC),
                        child: const Icon(Icons.image_not_supported),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                            height: 1.2,
                          ),
                        ),
                        if (film.originalTitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            film.originalTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF52796F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Badge skor Rotten Tomatoes berwarna hijau emerald
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFD166),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Skor ${film.rtScore}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Deretan pill informasi Tahun Rilis & Durasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatPill(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tahun Rilis',
                      value: film.releaseDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatPill(
                      icon: Icons.schedule_rounded,
                      label: 'Durasi Tayang',
                      value: '${film.runningTime} Menit',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Kartu informasi Sutradara & Produser
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDCE8E1)),
                ),
                child: Column(
                  children: [
                    _buildPersonRow(
                      icon: Icons.movie_filter_rounded,
                      role: 'Sutradara',
                      name: film.director,
                    ),
                    const Divider(height: 22, color: Color(0xFFE6F0EA)),
                    _buildPersonRow(
                      icon: Icons.person_pin_rounded,
                      role: 'Produser',
                      name: film.producer,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kartu Sinopsis Film
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDCE8E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 20,
                          color: primaryGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sinopsis Cerita',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      film.description,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: Color(0xFF2F483E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tombol aksi Simpan ke Koleksi (lintas Public API ke Laravel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _openSaveToCollectionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bookmark_add_rounded),
                  label: Text(
                    _isSaving ? 'Memuat Kategori...' : 'Simpan ke Koleksi',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kotak kecil untuk Tahun Rilis & Durasi
  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8E1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD8F3DC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2D6A4F)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF52796F),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget baris info Sutradara & Produser
  Widget _buildPersonRow({
    required IconData icon,
    required String role,
    required String name,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2D6A4F)),
        const SizedBox(width: 10),
        Text(
          role,
          style: const TextStyle(
            color: Color(0xFF52796F),
            fontSize: 13.5,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            name,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B4332),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}