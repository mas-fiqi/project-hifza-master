// ================================
// 🕌 File: home_screen.dart
// ================================
// Fungsi: Menampilkan tampilan utama aplikasi “The Hafiz”
// di mana pengguna bisa memilih menu seperti:
// - Uji hafalan tulisan
// - Uji hafalan suara
// - Skor hafalan
// - Skor sambung ayat
//
// Semua menu ditampilkan dalam bentuk kartu interaktif.
// ================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔹 Import service yang dibutuhkan
// AudioService = menangani audio/murottal
// SpeechService = menangani pengenalan suara (speech-to-text)
import '../../services/audio_service.dart';
import '../../services/speech_service.dart';

// 🔹 Import widget tambahan (misalnya search bar di halaman utama)
import 'widgets/search_bar.dart';

// ================================
// Kelas utama HomeScreen
// ================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ================================
// State HomeScreen
// Di sinilah logika dan UI utama dibuat
// ================================
class _HomeScreenState extends State<HomeScreen> {
  // Variabel untuk menyimpan kata pencarian dari SearchBar
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 🔹 Ambil service audio dan speech menggunakan Provider
    // agar bisa digunakan di seluruh aplikasi tanpa harus passing data manual.
    final audio = Provider.of<AudioService>(context, listen: false);
    final speech = Provider.of<SpeechService>(context, listen: false);

    // ================================
    // 🔹 Scaffold = kerangka utama tampilan
    // ================================
    return Scaffold(
      backgroundColor: Colors.grey[100], // warna latar belakang
      appBar: AppBar(
        automaticallyImplyLeading: false, // hilangkan tombol back otomatis
        backgroundColor: Colors.teal, // warna utama header
        elevation: 0, // tanpa bayangan
        title: const Text(
          'The Hafiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // judul di tengah
      ),

      // ================================
      // 🔹 Body utama aplikasi (bisa digulir)
      // ================================
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ========================================
            // 🔹 Bagian Header (sambutan pengguna)
            // ========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Selamat Datang, Belga 👋',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tetap semangat menjaga hafalanmu hari ini!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ========================================
            // 🔹 Bagian “Terakhir Dibaca”
            // ========================================
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Terakhir dibaca',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Surah Al-Fatihah ayat 1',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // ========================================
            // 🔹 Search Bar (pencarian surat)
            // ========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarWidget(
                onChanged: (query) {
                  // setiap kali teks berubah, update variabel searchQuery
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),

            const SizedBox(height: 8),

            // ========================================
            // 🔹 MENU 1 — Uji Hafalan (pindah ke atas)
            // ========================================
            _buildMenuSection(
              title: 'Uji Hafalan',
              children: [
                _buildMenuCard(
                  icon: Icons.edit_note,
                  title: "Uji Hafalan Dengan Tulisan",
                  subtitle: 'Perkuat hafalan dengan latihan soal tulisan',
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.pushNamed(context, '/uji_tulisan');
                  },
                ),
                _buildMenuCard(
                  icon: Icons.mic,
                  title: "Uji Hafalan Dengan Suara",
                  subtitle: 'Uji hafalan dengan membaca ayat menggunakan suara',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pushNamed(context, '/uji_suara');
                  },
                ),
              ],
            ),

            // ========================================
            // 🔹 MENU 2 — Skor Hafalan (pindah ke bawah)
            // ========================================
            _buildMenuSection(
              title: 'Skor Hafalan',
              children: [
                _buildMenuCard(
                  icon: Icons.assessment,
                  title: "Skor Hafalan",
                  subtitle: 'Lihat pencapaian hafalan dan progres kamu',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/skor_hafalan');
                  },
                ),
                _buildMenuCard(
                  icon: Icons.stacked_line_chart,
                  title: "Skor Sambung Ayat",
                  subtitle: 'Nilai hasil sambung ayat dari hafalanmu',
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.pushNamed(context, '/skor_sambung_ayat');
                  },
                ),
              ],
            ),

            // ========================================
            // 🔹 Bagian “Tentang Aplikasi”
            // ========================================
            const SizedBox(height: 16),
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // 🔹 Widget Helper untuk membuat Section Menu
  // ==================================================
  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul section
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Tambahkan semua kartu (children) di section ini
          ...children,
        ],
      ),
    );
  }

  // ==================================================
  // 🔹 Widget Helper untuk membuat kartu menu
  // ==================================================
  Widget _buildMenuCard({
    required IconData icon, // ikon di kiri
    required String title, // judul utama
    required String subtitle, // deskripsi singkat
    required Color color, // warna tema ikon
    VoidCallback? onTap, // aksi saat diklik
  }) {
    return GestureDetector(
      onTap: onTap, // jalankan fungsi saat kartu ditekan
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // warna latar belakang kartu
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Efek bayangan lembut
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🔹 Lingkaran ikon di kiri
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 24,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // 🔹 Teks judul dan subjudul
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Ikon panah kecil di kanan
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
