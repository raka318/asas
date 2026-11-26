import 'package:flutter/material.dart';
import '../constants/api_constant.dart';
import '../models/user_model.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';

/// Halaman Profil Pengguna (/api/user), Identitas Siswa Pembuat, Tentang Aplikasi, dan Logout
class ProfileAboutPage extends StatefulWidget {
  const ProfileAboutPage({super.key});

  @override
  State<ProfileAboutPage> createState() => _ProfileAboutPageState();
}

class _ProfileAboutPageState extends State<ProfileAboutPage> {
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userFuture;
  bool _isLoggingOut = false;

  // Data identitas siswa pembuat aplikasi
  static const String namaSiswa = 'Raka Muhammad Alfathir';
  static const String kelasSiswa = 'XII RPL 2';
  static const String nomorAbsen = '01';

  // Palet warna utama yang seragam dengan halaman Explore dan Koleksi
  static const Color _softSageBg = Color(0xFFEFF6F2);
  static const Color _darkGreen = Color(0xFF1B4332);
  static const Color _primaryGreen = Color(0xFF2D6A4F);
  static const Color _mutedGreen = Color(0xFF52796F);
  static const Color _borderGreen = Color(0xFFDCE8E1);
  static const Color _mintGreen = Color(0xFFD8F3DC);

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getCurrentUser();
  }

  // Memuat ulang data profil pengguna dari endpoint /api/user
  void _refreshUser() {
    setState(() {
      _userFuture = _authService.getCurrentUser();
    });
  }

  // Menampilkan dialog konfirmasi sebelum menjalankan proses logout
  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Sesi login kamu akan diakhiri dan kamu perlu masuk kembali untuk mengakses koleksi.',
          style: TextStyle(color: Color(0xFF2F483E), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: _mutedGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _isLoggingOut = true);
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouting.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softSageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header atas yang seragam dengan halaman Explore dan Koleksi
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil & Tentang',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                        Text(
                          'Informasi akun & identitas pembuat aplikasi',
                          style: TextStyle(
                            fontSize: 13,
                            color: _mutedGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderGreen),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: _primaryGreen,
                      ),
                      onPressed: _refreshUser,
                      tooltip: 'Muat ulang profil',
                    ),
                  ),
                ],
              ),
            ),

            // Konten utama halaman profil yang dapat digulir
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 115),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bagian 1: Kartu Profil Akun Login dari Endpoint /api/user
                    _buildUserProfileCard(),
                    const SizedBox(height: 16),

                    // Bagian 2: Kartu Identitas Siswa Pembuat Aplikasi
                    _buildCreatorIdentityCard(),
                    const SizedBox(height: 16),

                    // Bagian 3: Kartu Ringkasan Tentang Aplikasi
                    _buildAboutAppCard(),
                    const SizedBox(height: 22),

                    // Bagian 4: Tombol Logout
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoggingOut ? null : _confirmAndLogout,
                        icon: _isLoggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(
                          _isLoggingOut ? 'Sedang Keluar...' : 'Logout Akun',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu informasi akun pengguna dari /api/user dengan avatar bernuansa emerald
  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: _primaryGreen),
              ),
            );
          }

          final user = snapshot.data;
          final displayName = (user?.name != null && user!.name.isNotEmpty)
              ? user.name
              : 'Pengguna Terautentikasi';
          final initial = displayName[0].toUpperCase();

          return Column(
            children: [
              // Avatar gradasi hijau emerald dengan inisial nama pengguna
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryGreen, Color(0xFF52B788)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '-',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _mutedGreen,
                ),
              ),
              const SizedBox(height: 12),

              // Badge status autentikasi token Sanctum
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _mintGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 15,
                      color: _primaryGreen,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Akun Terautentikasi • Sanctum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Kartu identitas siswa pembuat aplikasi dengan gaya baris berikon
  Widget _buildCreatorIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
          const Row(
            children: [
              Icon(Icons.badge_rounded, size: 20, color: _primaryGreen),
              SizedBox(width: 8),
              Text(
                'Identitas Pembuat Aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nama',
            value: namaSiswa,
          ),
          const Divider(height: 22, color: Color(0xFFE6F0EA)),
          _buildInfoRow(
            icon: Icons.school_outlined,
            label: 'Kelas',
            value: kelasSiswa,
          ),
          const Divider(height: 22, color: Color(0xFFE6F0EA)),
          _buildInfoRow(
            icon: Icons.format_list_numbered_rounded,
            label: 'No. Absen',
            value: nomorAbsen,
          ),
          const Divider(height: 22, color: Color(0xFFE6F0EA)),
          _buildInfoRow(
            icon: Icons.api_rounded,
            label: 'Public API',
            value: ApiConstant.publicApiUrl,
          ),
        ],
      ),
    );
  }

  // Kartu ringkas tentang aplikasi Ghibli Collection
  Widget _buildAboutAppCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: _primaryGreen),
              SizedBox(width: 8),
              Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ghibli Collection adalah aplikasi katalog dan watchlist pribadi untuk menjelajahi karya animasi Studio Ghibli serta mencatat kategori tontonan, rating, dan ulasan singkat.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF2F483E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTechChip('Flutter UI'),
              _buildTechChip('Laravel Sanctum'),
              _buildTechChip('Studio Ghibli API'),
            ],
          ),
        ],
      ),
    );
  }

  // Widget baris detail berikon yang konsisten dengan ExploreDetailPage
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _primaryGreen),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _mutedGreen,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _darkGreen,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  // Widget badge kecil untuk label teknologi aplikasi
  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _softSageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGreen),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: _primaryGreen,
        ),
      ),
    );
  }
}