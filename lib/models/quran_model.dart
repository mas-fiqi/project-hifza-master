// lib/models/quran_model.dart
class Ayat {
  final int index; // nomor ayat (1-based)
  final String text; // teks arab
  final String translation; // optional
  final int? surahId;
  final String? surahName;

  Ayat({
    required this.index, 
    required this.text, 
    this.translation = '', 
    this.surahId, 
    this.surahName
  });

  factory Ayat.fromJson(Map<String, dynamic> j) {
    return Ayat(
      index: (j['index'] ?? j['numberInSurah'] ?? j['number'] ?? 0) as int,
      text: (j['text'] ?? j['arab'] ?? '') as String,
      translation: (j['translation'] ?? j['terjemahan'] ?? '') as String,
      surahId: j['surahId'] ?? j['surah_number'],
      surahName: j['surahName'] ?? j['surah_name'],
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
  }
}
