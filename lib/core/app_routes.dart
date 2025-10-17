import 'package:flutter/material.dart';
import 'package:hifzh_master/screens/home/home_screen.dart';
import 'package:hifzh_master/screens/splash/splash_screen.dart';
import 'package:hifzh_master/screens/home/surah_list_screen.dart'; 

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/home': (context) => const HomeScreen(),
    '/surah_list': (context) => const SurahListScreen(),
  };
}
