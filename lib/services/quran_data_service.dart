import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hifzh_master/data/surah_data.dart';

class QuranDataService {
  static final QuranDataService _instance = QuranDataService._internal();
  factory QuranDataService() => _instance;
  QuranDataService._internal();

  Map<String, dynamic> _quranData = {};
  List<Map<String, dynamic>> _surahList = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final String response = await rootBundle.loadString('assets/data/quran_full.json');
      _quranData = json.decode(response);
      
      // Generate surah list for dropdown (using first entry of each surah to get minimal info if needed)
      // For now, we will just use numbers 1-114 as base surah info is usually in a separate file
      // But we can extract count from _quranData
      _surahList = _quranData.keys.map((k) => {
        "nomor": int.parse(k),
        "jumlahAyat": (_quranData[k] as List).length
      }).toList();
      _surahList.sort((a, b) => (a['nomor'] as int).compareTo(b['nomor'] as int));

      _isLoaded = true;
    } catch (e) {
      print("Error loading quran_full.json: $e");
    }
  }

  List<Map<String, dynamic>> getSurahList() => _surahList;

  List<Map<String, dynamic>> getAyats(int surahId) {
    return List<Map<String, dynamic>>.from(_quranData[surahId.toString()] ?? []);
  }

  /// Ambil rentang ayat berdasarkan struktur Juz yang benar
  List<Map<String, dynamic>> getJuzAyats(int startSurah, int startAyat, int endSurah, int endAyat) {
    List<Map<String, dynamic>> results = [];
    
    for (int s = startSurah; s <= endSurah; s++) {
      final allAyats = getAyats(s);
      int from = (s == startSurah) ? startAyat : 1;
      int to = (s == endSurah) ? endAyat : allAyats.length;
      
      // Safety check
      if (from > allAyats.length) continue;
      if (to > allAyats.length) to = allAyats.length;

      for (int a = from; a <= to; a++) {
        var ayatData = Map<String, dynamic>.from(allAyats[a - 1]);
        // Berikan flag jika ini adalah ayat pertama surah di dalam rentang juz (kecuali surah pertama juz jika itu bukan ayat 1)
        ayatData['isFirstAyatOfSurah'] = (a == 1);
        ayatData['isStartOfJuzChunk'] = (s == startSurah && a == startAyat);
        ayatData['surah_id'] = s;
        try {
           ayatData['surah_name'] = SurahData.allSurahNames[s - 1];
        } catch (_) {
           ayatData['surah_name'] = "Surah $s";
        }
        results.add(ayatData);
      }
    }
    return results;
  }

  Map<String, dynamic>? getAyat(int surahId, int ayatNo) {
    final ayats = getAyats(surahId);
    if (ayatNo <= 0 || ayatNo > ayats.length) return null;
    return ayats[ayatNo - 1];
  }
}
