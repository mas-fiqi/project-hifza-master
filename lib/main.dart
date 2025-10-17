// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ==== IMPORT TAMBAHAN ====
import 'core/app_routes.dart';
import 'data/local_db/hive_manager.dart';
import 'services/audio_service.dart';
import 'services/speech_service.dart';
import 'screens/splash/splash_screen.dart';

// ==== IMPORT SCREEN BARU ====
import 'screens/surah/surah_list_screen.dart';
import 'screens/murottal/murottal_page_screen.dart';
import 'screens/uji/uji_tulisan_screen.dart';
import 'screens/uji/uji_suara_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await HiveManager.registerAdapters();
  await HiveManager.openBoxes();

  // Jalankan aplikasi
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
        title: 'The Hafiz',
        // ==== ROUTE TAMBAHAN DI SINI ====
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/surah_list': (context) => const SurahListScreen(),
          '/murottal_page': (context) => const MurottalPageScreen(),
          '/uji_tulisan': (context) => const UjiTulisanScreen(),
          '/uji_suara': (context) => const UjiSuaraScreen(),
        },
      ),
    );
  }
}
