// lib/models/quran_model.dart
class Ayat {
  final int index; // nomor ayat (1-based)
  final String text; // teks arab (atau arab + translit jika ada)
  final String translation; // optional

  Ayat({required this.index, required this.text, this.translation = ''});

  factory Ayat.fromJson(Map<String, dynamic> j) => Ayat(
        index: j['index'] as int,
        text: j['text'] as String,
        translation: j['translation'] as String? ?? '',
      );
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

  factory Surah.fromJson(Map<String, dynamic> j) => Surah(
        nomor: j['nomor'] as int,
        nama: j['nama'] as String,
        namaLatin: j['namaLatin'] as String,
        jumlahAyat: j['jumlahAyat'] as int,
        juz: j['juz'] as int? ?? 0,
        ayat: (j['ayat'] as List<dynamic>? ?? [])
            .map((e) => Ayat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
