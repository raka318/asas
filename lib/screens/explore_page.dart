import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/film_model.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';

/// Halaman eksplorasi film Studio Ghibli dengan tampilan Poster Grid modern
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final PublicApiService _publicApiService = PublicApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<FilmModel>> _filmsFuture;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Hayao Miyazaki',
    'Isao Takahata',
    'Skor 95%+',
  ];

  @override
  void initState() {
    super.initState();
    _filmsFuture = _publicApiService.fetchFilms();
  }

  // Memuat ulang data dari Public API
  void _refreshData() {
    setState(() {
      _filmsFuture = _publicApiService.fetchFilms();
    });
  }

  // Menyaring daftar film berdasarkan kata kunci pencarian dan chip filter
  List<FilmModel> _applyFilters(List<FilmModel> films) {
    return films.where((film) {
      final matchesSearch = film.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          film.director.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Hayao Miyazaki') {
        return film.director.contains('Hayao Miyazaki');
      } else if (_selectedFilter == 'Isao Takahata') {
        return film.director.contains('Isao Takahata');
      } else if (_selectedFilter == 'Skor 95%+') {
        final score = int.tryParse(film.rtScore) ?? 0;
        return score >= 95;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header judul & tombol refresh
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Ghibli',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      Text(
                        'Temukan karya animasi terbaik Studio Ghibli',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF52796F),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCE8E1)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF2D6A4F),
                      ),
                      onPressed: _refreshData,
                      tooltip: 'Muat ulang',
                    ),
                  ),
                ],
              ),
            ),

            // Kolom pencarian judul film atau sutradara
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari judul film atau sutradara...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF74958A),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF2D6A4F),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDCE8E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDCE8E1)),
                  ),
                ),
              ),
            ),

            // Deretan chip filter horizontal bergaya kapsul
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: const Color(0xFF2D6A4F),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF2D6A4F),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFFC7DDD1),
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Konten utama berupa Grid Poster Film
            Expanded(
              child: FutureBuilder<List<FilmModel>>(
                future: _filmsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2D6A4F),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 56,
                              color: Color(0xFF52796F),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gagal memuat data:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _refreshData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredFilms = _applyFilters(snapshot.data ?? []);
                  if (filteredFilms.isEmpty) {
                    return const Center(
                      child: Text('Film yang dicari tidak ditemukan.'),
                    );
                  }

                  // GridView responsif (2 kolom di HP, otomatis rapi di layar lebar)
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      childAspectRatio: 0.66,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filteredFilms.length,
                    itemBuilder: (context, index) {
                      final film = filteredFilms[index];
                      return _buildPosterCard(film);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu poster individual dengan gradasi bawah & badge skor kaca
  Widget _buildPosterCard(FilmModel film) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouting.exploreDetail,
          arguments: film,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar poster film penuh
              Image.network(
                film.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFD8F3DC),
                  child: const Icon(
                    Icons.movie_rounded,
                    size: 48,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
              ),

              // Lapisan gradasi gelap-hijau di bawah agar judul terbaca jelas
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0B1F16).withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),

              // Badge rating efek kaca di pojok kanan atas
              Positioned(
                top: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD166),
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${film.rtScore}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Informasi judul film, tahun rilis, dan sutradara di bagian bawah kartu
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52B788).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        film.releaseDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      film.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      film.director,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}