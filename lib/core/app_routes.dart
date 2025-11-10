import 'package:flutter/material.dart';

// ✅ Import semua screen latihan
import 'package:hifzh_master/screens/surah/surah_list_screen.dart';
import 'package:hifzh_master/screens/skor/skor_hafalan_screen.dart';
import 'package:hifzh_master/screens/home/home_screen.dart';
import 'package:hifzh_master/screens/splash/splash_screen.dart';
import 'package:hifzh_master/screens/uji/latihan_makharij_screen.dart';
import 'package:hifzh_master/screens/uji/latihan_tajwid_screen.dart';
import 'package:hifzh_master/screens/uji/hafalan_kalimat_screen.dart';
import 'package:hifzh_master/screens/uji/uji_suara_option_screen.dart';


class AppRoutes {
  // existing constants...
  static const String splash = '/';
  static const String home = '/home';

  // <-- Tambahkan ini:
  static const String surahList = '/surah_list';
  static const String skorHafalan = '/skor_hafalan';
  // pencaria 
  static const searchOverlay = '/search_overlay';

  // route latihan (jika kamu sudah pakai)
  static const String latihanMakharij = '/latihan_makharij';
  static const String latihanTajwid = '/latihan_tajwid';
  static const String hafalanKalimat = '/hafalan_kalimat';
  static const String ujiSuaraOption = '/uji_suara_option';

  // generateRoute (contoh lengkap)
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case surahList:
        return MaterialPageRoute(builder: (_) => const SurahListScreen());
      case skorHafalan:
        return MaterialPageRoute(builder: (_) => const SkorHafalanScreen());
      case latihanMakharij:
        return MaterialPageRoute(builder: (_) => const LatihanMakharijScreen());
      case latihanTajwid:
        return MaterialPageRoute(builder: (_) => const LatihanTajwidScreen());
      case hafalanKalimat:
        return MaterialPageRoute(builder: (_) => const HafalanKalimatScreen());
      case ujiSuaraOption:
        return MaterialPageRoute(builder: (_) => const UjiSuaraOptionScreen());

      // jika ada rute kompleks yang butuh argumen, tangani di sini...
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan: ${settings.name}')),
          ),
        );
    }
  }
}
