// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import 'core/app_routes.dart'; // opsional bila pakai generateRoute
import 'data/local_db/hive_manager.dart';
import 'services/audio_service.dart';
import 'services/speech_service.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/surah/surah_list_screen.dart';
import 'screens/search/search_overlay_screen.dart';
import 'screens/skor/skor_hafalan_screen.dart';
import 'screens/skor/skor_sambung_ayat_screen.dart';
import 'screens/uji/kitab_suci_screen.dart';
import 'screens/uji/uji_suara_screen.dart';
import 'screens/uji/latihan_makharij_screen.dart';
import 'screens/uji/latihan_tajwid_screen.dart';
import 'screens/quran/quran_list_screen.dart';

import 'screens/uji/uji_suara_option_screen.dart';
//import 'screens/surah/surah_detail_screen.dart';
//import 'screens/surah/surah_list_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive (Hanya di sini)
  await HiveManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    final speechService = SpeechService();

    return MultiProvider(
      providers: [
        Provider<AudioService>.value(value: audioService),
        Provider<SpeechService>.value(value: speechService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hifzh Master',
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/surah_list': (context) => const SurahListScreen(),
          '/skor_hafalan': (context) => const SkorHafalanScreen(),
          '/skor_sambung_ayat': (context) => const SkorSambungAyatScreen(),
          '/uji_tulisan': (context) => const UjiTulisanScreen(),
          '/uji_suara': (context) => const UjiSuaraScreen(),
          '/latihan_makharij': (context) => const LatihanMakharijScreen(),
          '/latihan_tajwid': (context) => const LatihanTajwidScreen(),
          '/uji_suara_option': (context) => const UjiSuaraOptionScreen(),
          '/search_overlay': (context) => const SearchOverlayScreen(),
          // Jangan daftarkan layar yang butuh argumen sebagai const tanpa arg.
        },
        theme: ThemeData(
          primaryColor: const Color(0xFF006442),
          scaffoldBackgroundColor: const Color(0xFFFDFEF6),
        ),
      ),
    );
  }
}
