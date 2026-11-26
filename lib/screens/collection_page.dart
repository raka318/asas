import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category_model.dart';
import '../models/collection_model.dart';
import '../models/film_model.dart';
import '../services/crud_service.dart';
import '../services/public_api_service.dart';

/// Halaman manajemen CRUD 2 Tabel Laravel dengan auto-refresh setelah tambah/edit/hapus
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final CrudService _crudService = CrudService();
  final PublicApiService _publicApiService = PublicApiService();
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];
  List<CollectionModel> _collections = [];
  List<FilmModel> _ghibliFilms = [];
  int? _selectedFilterCategoryId;
  String _searchQuery = '';
  bool _isLoading = true;

  // Palet warna utama yang seragam dengan halaman Explore
  static const Color _softSageBg = Color(0xFFEFF6F2);
  static const Color _darkGreen = Color(0xFF1B4332);
  static const Color _primaryGreen = Color(0xFF2D6A4F);
  static const Color _mutedGreen = Color(0xFF52796F);
  static const Color _borderGreen = Color(0xFFDCE8E1);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Memuat data kategori, koleksi Laravel, dan daftar film dari Public API Ghibli
  Future<void> _loadAllData({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final categories = await _crudService.getCategories();
      final collections = await _crudService.getCollections(
        categoryId: _selectedFilterCategoryId,
      );

      // Mengambil daftar film dari ghibliapi secara terpisah agar aman saat offline
      List<FilmModel> films = _ghibliFilms;
      if (films.isEmpty) {
        try {
          films = await _publicApiService.fetchFilms();
        } catch (_) {
          // Abaikan jika API publik gagal; form akan memakai input teks cadangan
        }
      }

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _collections = collections;
        _ghibliFilms = films;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Gagal memuat data: $e', isError: true);
    }
  }

  // Memfilter daftar item koleksi berdasarkan chip kategori yang dipilih
  Future<void> _filterCollections(int? categoryId) async {
    setState(() {
      _selectedFilterCategoryId = categoryId;
      _isLoading = true;
    });
    try {
      final collections = await _crudService.getCollections(
        categoryId: categoryId,
      );
      if (!mounted) return;
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Gagal memfilter koleksi: $e', isError: true);
    }
  }

  // Menyaring koleksi secara lokal berdasarkan kata kunci pencarian judul atau catatan
  List<CollectionModel> get _filteredCollections {
    if (_searchQuery.trim().isEmpty) return _collections;
    final query = _searchQuery.toLowerCase();
    return _collections.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query);
      final noteMatch = (item.note ?? '').toLowerCase().contains(query);
      return titleMatch || noteMatch;
    }).toList();
  }

  // Menampilkan notifikasi singkat (SnackBar) di bagian bawah layar
  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red.shade700 : _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // =========================================================================
  // BOTTOM SHEET KELOLA KATEGORI (CRUD TABEL 1)
  // =========================================================================
  void _showCategoryManagerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _softSageBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  // Garis pegangan modal di bagian atas
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7DDD1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header modal kelola kategori + tombol tambah kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Kategori',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _darkGreen,
                            ),
                          ),
                          Text(
                            'Atur status atau kelompok tontonanmu',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _mutedGreen,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showCategoryForm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Kategori'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Daftar kategori yang tersimpan di database
                  Expanded(
                    child: _categories.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada kategori. Tambahkan satu untuk mulai!',
                              style: TextStyle(color: _mutedGreen),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _borderGreen),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFFD8F3DC),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: _primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _darkGreen,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (category.description != null &&
                                              category.description!.isNotEmpty)
                                            Text(
                                              category.description!,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: _mutedGreen,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: _primaryGreen,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(sheetContext);
                                        _showCategoryForm(category: category);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        if (sheetContext.mounted) {
                                          Navigator.pop(sheetContext);
                                        }
                                        bool ok = false;
                                        try {
                                          ok = await _crudService
                                              .deleteCategory(category.id);
                                        } catch (_) {}

                                        // Reset filter jika kategori yang dihapus sedang aktif dipilih
                                        if (_selectedFilterCategoryId ==
                                            category.id) {
                                          _selectedFilterCategoryId = null;
                                        }

                                        await _loadAllData();
                                        final masihAda = _categories.any(
                                          (c) => c.id == category.id,
                                        );

                                        if (ok || !masihAda) {
                                          _showMessage('Kategori dihapus');
                                        } else {
                                          _showMessage(
                                            'Gagal menghapus kategori',
                                            isError: true,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // DIALOG FORM TAMBAH & EDIT TABEL 1 (KATEGORI) DENGAN AUTO-REFRESH
  // =========================================================================
  void _showCategoryForm({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            category == null ? 'Tambah Kategori' : 'Edit Kategori',
            style: const TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Misal: Mau Nonton, Selesai',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama kategori wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
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
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: _mutedGreen)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      // Tampilkan loading di tombol simpan sambil menunggu proses API selesai
                      setDialogState(() => isSubmitting = true);
                      final namaBaru = nameController.text.trim();
                      final deskripsiBaru = descController.text.trim();
                      bool success = false;

                      try {
                        if (category == null) {
                          success = await _crudService.createCategory(
                            namaBaru,
                            deskripsiBaru,
                          );
                        } else {
                          success = await _crudService.updateCategory(
                            category.id,
                            namaBaru,
                            deskripsiBaru,
                          );
                        }
                      } catch (_) {
                        // Lanjut memuat ulang data untuk memastikan status terbaru di server
                      }

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      // Segarkan data langsung dari Laravel agar chip kategori langsung muncul
                      await _loadAllData();

                      final sudahTersimpan = _categories.any(
                        (c) => c.name.toLowerCase() == namaBaru.toLowerCase(),
                      );

                      if (success || sudahTersimpan) {
                        _showMessage(
                          category == null
                              ? 'Kategori berhasil ditambahkan'
                              : 'Kategori berhasil diperbarui',
                        );
                      } else {
                        _showMessage('Gagal menyimpan kategori', isError: true);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // DIALOG FORM TAMBAH & EDIT TABEL 2 (ITEM KOLEKSI) DENGAN AUTO-REFRESH
  // =========================================================================
  void _showCollectionForm({CollectionModel? item}) {
    if (_categories.isEmpty) {
      _showMessage(
        'Buat minimal 1 kategori terlebih dahulu lewat ikon folder!',
        isError: true,
      );
      _showCategoryForm();
      return;
    }

    final manualTitleController = TextEditingController(text: item?.title ?? '');
    final noteController = TextEditingController(text: item?.note ?? '');
    final ratingController = TextEditingController(text: item?.rating ?? '');

    int selectedCategoryId = item?.categoryId ?? _categories.first.id;
    String? selectedFilmTitle =
        (item != null && item.title.isNotEmpty) ? item.title : null;
    bool isSubmitting = false;

    // Susun opsi judul film dari Public API Ghibli
    final List<DropdownMenuItem<String>> filmDropdownItems = _ghibliFilms
        .map(
          (film) => DropdownMenuItem<String>(
            value: film.title,
            child: Text(
              '${film.title} (${film.releaseDate})',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();

    // Jika mode edit dan judul lama tidak ada di daftar API, tambahkan ke opsi agar aman
    if (selectedFilmTitle != null &&
        !_ghibliFilms.any((f) => f.title == selectedFilmTitle)) {
      filmDropdownItems.insert(
        0,
        DropdownMenuItem<String>(
          value: selectedFilmTitle,
          child: Text(selectedFilmTitle, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            item == null ? 'Tambah ke Koleksi' : 'Edit Koleksi',
            style: const TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown 1: Memilih Kategori Tontonan dari Tabel 1 Laravel
                  DropdownButtonFormField<int>(
                    value: _categories.any((c) => c.id == selectedCategoryId)
                        ? selectedCategoryId
                        : _categories.first.id,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Kategori Tontonan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: isSubmitting
                        ? null
                        : (val) {
                            if (val != null) {
                              setDialogState(() => selectedCategoryId = val);
                            }
                          },
                  ),
                  const SizedBox(height: 12),

                  // Dropdown 2: Memilih Judul Film langsung dari Public API Ghibli
                  if (filmDropdownItems.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedFilmTitle,
                      isExpanded: true,
                      hint: const Text('Pilih film Studio Ghibli...'),
                      decoration: InputDecoration(
                        labelText: 'Judul Film Ghibli',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: filmDropdownItems,
                      onChanged: isSubmitting
                          ? null
                          : (val) {
                              setDialogState(() => selectedFilmTitle = val);
                            },
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Silakan pilih film terlebih dahulu'
                          : null,
                    )
                  else
                    // Input teks cadangan apabila data Public API gagal dimuat
                    TextFormField(
                      controller: manualTitleController,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        labelText: 'Judul Film Ghibli',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Judul film wajib diisi'
                          : null,
                    ),
                  const SizedBox(height: 12),

                  // Input Rating Pribadi khusus angka 1 - 10
                  TextFormField(
                    controller: ratingController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Rating Pribadi (1 - 10)',
                      hintText: 'Contoh: 9',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final nilaiRating = int.tryParse(v.trim());
                      if (nilaiRating == null) {
                        return 'Rating harus berupa angka';
                      }
                      if (nilaiRating < 1 || nilaiRating > 10) {
                        return 'Rating harus antara 1 sampai 10';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: noteController,
                    enabled: !isSubmitting,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan / Ulasan Singkat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: _mutedGreen)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      // Tampilkan indikator loading sambil mengirim data ke Laravel
                      setDialogState(() => isSubmitting = true);

                      final finalTitle = filmDropdownItems.isNotEmpty
                          ? selectedFilmTitle!.trim()
                          : manualTitleController.text.trim();
                      final finalNote = noteController.text.trim();
                      final finalRating = ratingController.text.trim();
                      bool success = false;

                      try {
                        if (item == null) {
                          success = await _crudService.createCollection(
                            categoryId: selectedCategoryId,
                            title: finalTitle,
                            note: finalNote,
                            rating: finalRating,
                          );
                        } else {
                          success = await _crudService.updateCollection(
                            id: item.id,
                            categoryId: selectedCategoryId,
                            title: finalTitle,
                            note: finalNote,
                            rating: finalRating,
                          );
                        }
                      } catch (_) {
                        // Lanjut memuat ulang data dari server
                      }

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      // Jika sedang memfilter kategori lain, arahkan ke "Semua" agar item baru langsung terlihat
                      if (item == null &&
                          _selectedFilterCategoryId != null &&
                          _selectedFilterCategoryId != selectedCategoryId) {
                        _selectedFilterCategoryId = null;
                      }

                      // Muat ulang koleksi dari Laravel agar kartu baru langsung tampil
                      await _loadAllData();

                      final sudahTersimpan = _collections.any(
                        (c) => c.title.toLowerCase() == finalTitle.toLowerCase(),
                      );

                      if (success || sudahTersimpan) {
                        _showMessage(
                          item == null
                              ? 'Film ditambahkan ke koleksi'
                              : 'Item koleksi diperbarui',
                        );
                      } else {
                        _showMessage(
                          'Gagal menyimpan item koleksi',
                          isError: true,
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // Konfirmasi sebelum menghapus item koleksi
  Future<void> _confirmDeleteItem(CollectionModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Koleksi?'),
        content: Text('Yakin ingin menghapus "${item.title}" dari koleksimu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool ok = false;
      try {
        ok = await _crudService.deleteCollection(item.id);
      } catch (_) {}

      await _loadAllData();
      final masihAda = _collections.any((c) => c.id == item.id);

      if (ok || !masihAda) {
        _showMessage('Item koleksi dihapus');
      } else {
        _showMessage('Gagal menghapus item koleksi', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedCollections = _filteredCollections;

    return Scaffold(
      backgroundColor: _softSageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header atas: Judul di kiri, tombol Kelola Kategori & + Tambah di kanan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koleksi Ghibli',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                        Text(
                          'Watchlist & ulasan film pribadimu',
                          style: TextStyle(
                            fontSize: 13,
                            color: _mutedGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Kelola Kategori (Tabel 1)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderGreen),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.folder_special_rounded,
                        color: _primaryGreen,
                      ),
                      onPressed: _showCategoryManagerSheet,
                      tooltip: 'Kelola Kategori',
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tombol Tambah Item Koleksi (Tabel 2)
                  ElevatedButton.icon(
                    onPressed: () => _showCollectionForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Kolom pencarian koleksi yang seragam dengan ExplorePage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari judul atau catatan di koleksimu...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF74958A),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: _primaryGreen,
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
                    borderSide: const BorderSide(color: _borderGreen),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _borderGreen),
                  ),
                ),
              ),
            ),

            // Deretan ChoiceChip filter kategori (Semua + kategori dari Tabel 1)
            SizedBox(
              height: 46,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(label: 'Semua', categoryId: null),
                  ..._categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildFilterChip(
                        label: cat.name,
                        categoryId: cat.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Konten daftar kartu koleksi film
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
                    )
                  : displayedCollections.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: _primaryGreen,
                          onRefresh: _loadAllData,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
                            itemCount: displayedCollections.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = displayedCollections[index];
                              return _buildCollectionCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget chip filter kategori bergaya kapsul
  Widget _buildFilterChip({required String label, required int? categoryId}) {
    final isSelected = _selectedFilterCategoryId == categoryId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _filterCollections(categoryId),
      selectedColor: _primaryGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : _primaryGreen,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? _primaryGreen : const Color(0xFFC7DDD1),
        ),
      ),
      showCheckmark: false,
    );
  }

  // Widget kartu item koleksi dengan desain modern & rapi
  Widget _buildCollectionCard(CollectionModel item) {
    final categoryName = item.category?.name ??
        _categories
            .firstWhere(
              (c) => c.id == item.categoryId,
              orElse: () => CategoryModel(id: 0, name: 'Tanpa Kategori'),
            )
            .name;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGreen),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon dekoratif film bernuansa hijau mint
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3DC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  color: _primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Judul film + badge kategori & skor rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // Badge nama kategori
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8F3DC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
                            ),
                          ),
                        ),

                        // Badge rating jika diisi pengguna
                        if (item.rating != null && item.rating!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFE199),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFE09F3E),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${item.rating}/10',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C5E1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol aksi Edit & Hapus yang ringkas di pojok kanan
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: _primaryGreen,
                    ),
                    onPressed: () => _showCollectionForm(item: item),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: Colors.red.shade600,
                    ),
                    onPressed: () => _confirmDeleteItem(item),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),

          // Kotak catatan pribadi jika tersedia
          if (item.note != null && item.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF6FAF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.note!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2F483E),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Tampilan saat daftar koleksi masih kosong
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFD8F3DC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_library_rounded,
                size: 44,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum ada film di koleksi ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkGreen,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tekan tombol "+ Tambah" di kanan atas untuk memilih film Ghibli atau simpan dari halaman Explore.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _mutedGreen),
            ),
          ],
        ),
      ),
    );
  }
}