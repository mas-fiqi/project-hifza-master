import 'dart:convert';
import 'package:http/http.dart' as http;

class Ayat {
  final int index;
  final String text;
  final String translation;
  Ayat({required this.index, required this.text, this.translation = ''});
  
  factory Ayat.fromJson(Map<String, dynamic> j) {
    return Ayat(
      index: (j['index'] ?? j['numberInSurah'] ?? j['number'] ?? 0) as int,
      text: (j['text'] ?? j['arab'] ?? '') as String,
      translation: (j['translation'] ?? j['terjemahan'] ?? '') as String,
    );
  }
}

class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final int juz;
  final List<Ayat> ayat;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.juz,
    required this.ayat,
  });

  factory Surah.fromJson(Map<String, dynamic> j) {
    try {
      var rawAyat = j['ayat'] ?? j['ayahs'];
      List<Ayat> parsedAyat = [];
      if (rawAyat is List) {
         parsedAyat = rawAyat.map((e) => Ayat.fromJson(e as Map<String, dynamic>)).toList();
      }
      return Surah(
        nomor: (j['nomor'] ?? j['number'] ?? 0) as int,
        nama: (j['nama'] ?? j['name'] ?? '') as String,
        namaLatin: (j['namaLatin'] ?? j['englishName'] ?? '') as String,
        jumlahAyat: (j['jumlahAyat'] ?? j['numberOfAyahs'] ?? 0) as int,
        juz: (j['juz'] ?? j['juzNumber'] ?? 0) as int,
        ayat: parsedAyat,
      );
    } catch(e, s) {
      print("FAIL SURAH PARSE: $j");
      print(e);
      print(s);
      rethrow;
    }
  }
}

void main() async {
  try {
    print("Fetching SURAH LIST...");
    var res = await http.get(Uri.parse('http://127.0.0.1:8000/api/quran/surah'));
    var decoded = json.decode(res.body);
    List<dynamic> data = [];
    if (decoded is List) data = decoded;
    else if (decoded is Map) data = decoded['data'] ?? decoded['surah'] ?? [];
    else data = [];
    
    data.map((j) => Surah.fromJson(j)).toList();
    print("SURAH LIST PARSED OK");

    print("Fetching JUZ DETAIL 1...");
    res = await http.get(Uri.parse('http://127.0.0.1:8000/api/quran/juz/1'));
    decoded = json.decode(res.body);
    data = [];
    if (decoded is List) data = decoded;
    else if (decoded is Map) {
      if (decoded['ayat'] is List) data = decoded['ayat'] as List;
      else if (decoded['juz'] is List) data = decoded['juz'] as List;
      else if (decoded['data'] is List) data = decoded['data'] as List;
      else if (decoded['data'] is Map) {
         final mapData = decoded['data'] as Map;
         data = mapData['ayahs'] ?? mapData['ayat'] ?? [];
      }
    }
    data.map((j) => Ayat.fromJson(j as Map<String, dynamic>)).toList();
    print("JUZ DETAIL PARSED OK");

  } catch(e,s) {
    print("MAIN ERROR:");
    print(e);
    print(s);
  }
}
