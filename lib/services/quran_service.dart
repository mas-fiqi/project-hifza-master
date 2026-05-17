// lib/services/quran_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hifzh_master/models/quran_model.dart';

class QuranService {
  
  static Future<List<Surah>> getSurahList() async {
    final url = 'https://equran.id/api/v2/surat';
    print("Fetching data from internet: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        
        if (decoded['code'] == 200 && decoded['data'] is List) {
           return (decoded['data'] as List).map((json) => Surah.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Gagal mengambil daftar Surah dari internet.');
      }
    } catch (e) {
      print("Error fetching SurahList: $e");
      rethrow;
    }
  }

  static Future<Surah> getSurahDetail(int id) async {
    final url = 'https://equran.id/api/v2/surat/$id';
    print("Fetching data from internet: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        
        if (decoded['code'] == 200 && decoded['data'] is Map) {
           var data = decoded['data'] as Map<String, dynamic>;
           if (data['ayat'] is List) {
             for (var a in (data['ayat'] as List)) {
               a['index'] = a['nomorAyat'];
               a['text'] = a['teksArab'];
               a['translation'] = a['teksIndonesia'];
             }
           }
           return Surah.fromJson(data);
        }
        throw Exception('Format data surah tidak dikenali');
      } else {
        throw Exception('Gagal mengambil detail Surah $id dari internet.');
      }
    } catch (e) {
      print("Error fetching SurahDetail $id: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getJuzList() async {
    // Return empty list so quran_list_screen generates 1-30 automatically
    return [];
  }

  static Future<List<Ayat>> getJuzDetail(int id) async {
    final arabUrl = 'https://api.alquran.cloud/v1/juz/$id/quran-uthmani';
    final indoUrl = 'https://api.alquran.cloud/v1/juz/$id/id.indonesian';
    print("Fetching juz data from internet: $arabUrl");
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(arabUrl)).timeout(const Duration(seconds: 15)),
        http.get(Uri.parse(indoUrl)).timeout(const Duration(seconds: 15)),
      ]);
      
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final arabDecoded = json.decode(utf8.decode(responses[0].bodyBytes));
        final indoDecoded = json.decode(utf8.decode(responses[1].bodyBytes));
        
        if (arabDecoded['code'] == 200 && arabDecoded['data'] != null && arabDecoded['data']['ayahs'] is List) {
           List<dynamic> arabAyahs = arabDecoded['data']['ayahs'];
           List<dynamic> indoAyahs = indoDecoded['data']['ayahs'] ?? [];
           
           for (int i = 0; i < arabAyahs.length; i++) {
             var a = arabAyahs[i];
             a['index'] = a['numberInSurah'];
             // text is already 'text' in alquran.cloud API
             if (i < indoAyahs.length) {
                a['translation'] = indoAyahs[i]['text'];
             }
             a['surahId'] = a['surah']['number'];
             a['surahName'] = a['surah']['englishName'];
           }
           return arabAyahs.map((j) => Ayat.fromJson(j)).toList();
        }
      }
      throw Exception('Gagal mengambil detail Juz $id dari internet.');
    } catch (e) {
      print("Error fetching JuzDetail $id: $e");
      rethrow;
    }
  }
}
