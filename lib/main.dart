// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_routes.dart';
import 'data/local_db/hive_manager.dart';
import 'services/audio_service.dart';
import 'services/speech_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive (dummy sementara)
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
        title: 'Tafit App',
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}
