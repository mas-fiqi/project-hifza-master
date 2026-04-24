// lib/data/juz_data.dart
class JuzData {
  static const Map<int, Map<String, dynamic>> juzMapping = {
    1: {"startSurah": 1, "startAyat": 1, "endSurah": 2, "endAyat": 141},
    2: {"startSurah": 2, "startAyat": 142, "endSurah": 2, "endAyat": 252},
    3: {"startSurah": 2, "startAyat": 253, "endSurah": 3, "endAyat": 92},
    4: {"startSurah": 3, "startAyat": 93, "endSurah": 4, "endAyat": 23},
    5: {"startSurah": 4, "startAyat": 24, "endSurah": 4, "endAyat": 147},
    6: {"startSurah": 4, "startAyat": 148, "endSurah": 5, "endAyat": 81},
    7: {"startSurah": 5, "startAyat": 82, "endSurah": 6, "endAyat": 110},
    8: {"startSurah": 6, "startAyat": 111, "endSurah": 7, "endAyat": 87},
    9: {"startSurah": 7, "startAyat": 88, "endSurah": 8, "endAyat": 40},
    10: {"startSurah": 8, "startAyat": 41, "endSurah": 9, "endAyat": 92},
    11: {"startSurah": 9, "startAyat": 93, "endSurah": 11, "endAyat": 5},
    12: {"startSurah": 11, "startAyat": 6, "endSurah": 12, "endAyat": 52},
    13: {"startSurah": 12, "startAyat": 53, "endSurah": 14, "endAyat": 52},
    14: {"startSurah": 15, "startAyat": 1, "endSurah": 16, "endAyat": 128},
    15: {"startSurah": 17, "startAyat": 1, "endSurah": 18, "endAyat": 74},
    16: {"startSurah": 18, "startAyat": 75, "endSurah": 20, "endAyat": 135},
    17: {"startSurah": 21, "startAyat": 1, "endSurah": 22, "endAyat": 78},
    18: {"startSurah": 23, "startAyat": 1, "endSurah": 25, "endAyat": 20},
    19: {"startSurah": 25, "startAyat": 21, "endSurah": 27, "endAyat": 55},
    20: {"startSurah": 27, "startAyat": 56, "endSurah": 29, "endAyat": 45},
    21: {"startSurah": 29, "startAyat": 46, "endSurah": 33, "endAyat": 30},
    22: {"startSurah": 33, "startAyat": 31, "endSurah": 36, "endAyat": 27},
    23: {"startSurah": 36, "startAyat": 28, "endSurah": 39, "endAyat": 31},
    24: {"startSurah": 39, "startAyat": 32, "endSurah": 41, "endAyat": 46},
    25: {"startSurah": 41, "startAyat": 47, "endSurah": 45, "endAyat": 37},
    26: {"startSurah": 46, "startAyat": 1, "endSurah": 51, "endAyat": 30},
    27: {"startSurah": 51, "startAyat": 31, "endSurah": 57, "endAyat": 29},
    28: {"startSurah": 58, "startAyat": 1, "endSurah": 66, "endAyat": 12},
    29: {"startSurah": 67, "startAyat": 1, "endSurah": 77, "endAyat": 50},
    30: {"startSurah": 78, "startAyat": 1, "endSurah": 114, "endAyat": 6},
  };

  static String getJuzLocation(int juz) {
    if (!juzMapping.containsKey(juz)) return "Unknown";
    final data = juzMapping[juz]!;
    return "Mulai Surah ${data['startSurah']} Ayat ${data['startAyat']}";
  }
}
