// lib/models/surah_model.dart
class SurahModel {
  final int nomor;
  final String nama;       // Arabic name
  final String namaLatin;  // Latin name
  final int jumlahAyat;
  final int juz;

  SurahModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.juz,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: json['jumlahAyat'] as int,
      juz: json.containsKey('juz') ? (json['juz'] as int) : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nomor': nomor,
        'nama': nama,
        'namaLatin': namaLatin,
        'jumlahAyat': jumlahAyat,
        'juz': juz,
      };
}
