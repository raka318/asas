import 'dart:ui';
import 'package:flutter/material.dart';
import 'explore_page.dart';
import 'collection_page.dart';
import 'profile_about_page.dart';

/// Halaman induk dengan footer melayang berdesain kaca buram (iOS Glassmorphism)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Daftar 3 halaman utama aplikasi
  final List<Widget> _pages = const [
    ExplorePage(),
    CollectionPage(),
    ProfileAboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengizinkan konten halaman mengalir di belakang footer agar efek blur terlihat
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            // Efek blur kaca buram seperti dock pada iPhone
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                // Warna kaca hijau gelap transparan agar ikon putih & mint kontras
                color: const Color(0xFF163024).withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4332).withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildGlassNavItem(
                    index: 0,
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: 'Explore',
                  ),
                  _buildGlassNavItem(
                    index: 1,
                    icon: Icons.collections_bookmark_outlined,
                    activeIcon: Icons.collections_bookmark_rounded,
                    label: 'Koleksi',
                  ),
                  _buildGlassNavItem(
                    index: 2,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget item navigasi dengan animasi kapsul hijau lembut saat aktif
  Widget _buildGlassNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF52B788).withValues(alpha: 0.26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF95D5B2).withValues(alpha: 0.45),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFFB7E4C7)
                  : Colors.white.withValues(alpha: 0.72),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}