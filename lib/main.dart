// ============================================
// 📄 File: lib/main.dart
// --------------------------------------------
// File utama aplikasi The Hafiz.
// Fungsinya seperti "pintu masuk" aplikasi Flutter.
// Di sini semua rute (halaman), service, dan database didaftarkan.
// ============================================

import 'package:flutter/material.dart'; // 🧱 Bahan dasar tampilan aplikasi (UI Flutter)
import 'package:provider/provider.dart'; // 🔗 Untuk berbagi data antar layar (Audio, Speech, dll)

// ==== IMPORT TAMBAHAN (memanggil file lain agar bisa dipakai di sini) ====
import 'core/app_routes.dart'; // 🗺️ Menyimpan daftar rute (opsional)
import 'data/local_db/hive_manager.dart'; // 💾 Mengatur database lokal Hive
import 'services/audio_service.dart'; // 🔊 Mengatur audio seperti murottal
import 'services/speech_service.dart'; // 🎙️ Untuk pengenalan suara saat uji hafalan
import 'screens/splash/splash_screen.dart'; // 🚀 Tampilan awal (loading screen)

// ==== IMPORT SCREEN BARU ====
// Folder "screens" isinya halaman-halaman utama aplikasi
import 'screens/surah/surah_list_screen.dart'; // 📖 Daftar surah Al-Qur'an
import 'screens/skor/skor_hafalan.dart'; // 🧾 Halaman skor hafalan
import 'screens/skor/skor_sambung_ayat_screen.dart'; // 🧾 Halaman skor sambung ayat
import 'screens/uji/uji_tulisan_screen.dart'; // ✍️ Ujian hafalan dengan tulisan
import 'screens/uji/uji_suara_screen.dart'; // 🎤 Ujian hafalan dengan suara

// ============================================
// 🧠 FUNGSI UTAMA: "main()"
// Titik awal aplikasi berjalan.
// Semua sistem disiapkan di sini sebelum app dijalankan.
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  // 🔧 Wajib dipanggil sebelum menjalankan kode async di Flutter.
  // Ibarat memastikan listrik nyala dulu sebelum pakai peralatan lain.

  await HiveManager.registerAdapters();
  // 🗃️ Daftarkan tipe data yang mau disimpan di database Hive.

  await HiveManager.openBoxes();
  // 📦 Buka "lemari data" Hive agar bisa digunakan di seluruh aplikasi.

  runApp(const MyApp());
  // 🚀 Jalankan aplikasi dengan widget utama MyApp (didefinisikan di bawah).
}

// ============================================
// 🏠 KELAS UTAMA: MyApp
// Ini adalah pondasi utama aplikasi (seperti rumah besar).
// Di dalamnya, semua pengaturan rute & service disiapkan.
// ============================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔊 Siapkan dua service utama: audio & speech
    // Supaya bisa dipakai di halaman mana pun lewat Provider
    final audioService = AudioService();
    final speechService = SpeechService();

    return MultiProvider(
      // 🧩 MultiProvider = tempat daftar semua service yang bisa diakses bersama
      providers: [
        Provider<AudioService>.value(value: audioService), // 🔊 Service untuk memutar audio
        Provider<SpeechService>.value(value: speechService), // 🎙️ Service untuk pengenalan suara
      ],

      // ============================================
      // 🌈 MaterialApp = wadah utama aplikasi Flutter
      // Di sinilah kita mengatur judul, tema, dan daftar halaman (route)
      // ============================================
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // ❌ Hilangkan tulisan "Debug" di pojok
        title: 'The Hafiz', // 🕌 Nama aplikasi di sistem

        // 🧭 Halaman pertama yang dibuka saat app dijalankan
        initialRoute: '/',

        // ============================================
        // 🗺️ Daftar RUTE / HALAMAN
        // Setiap key ('/nama_route') akan membuka widget tertentu.
        // ============================================
        routes: {
          '/': (context) => const SplashScreen(), // 🟢 Halaman awal saat app dibuka
          '/surah_list': (context) => const SurahListScreen(), // 📖 Daftar surah Al-Qur'an

          // ==== BAGIAN SKOR ====
          '/skor_hafalan': (context) => const SkorHafalanScreen(), // 🧾 Menampilkan nilai hafalan
          '/skor_sambung_ayat': (context) => const SkorSambungAyatScreen(), // 🔢 Menampilkan nilai sambung ayat

          // ==== BAGIAN UJIAN ====
          '/uji_tulisan': (context) => const UjiTulisanScreen(), // ✍️ Tes hafalan dengan mengetik ayat
          '/uji_suara': (context) => const UjiSuaraScreen(), // 🎤 Tes hafalan dengan membaca ayat
        },
      ),
    );
  }
}
