// lib/services/quran_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hifzh_master/models/quran_model.dart';
import 'package:hifzh_master/services/api_config.dart';

class QuranService {
  
  static Future<List<Surah>> getSurahList() async {
    final url = '${ApiConfig.baseUrl}/quran/surah';
    print("Fetching data from: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          data = decoded['data'] ?? decoded['surah'] ?? [];
        } else {
          data = [];
        }
        return data.map((json) => Surah.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil daftar Surah. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching SurahList: $e");
      rethrow;
    }
  }

  static Future<Surah> getSurahDetail(int id) async {
    final url = '${ApiConfig.baseUrl}/quran/surah/$id';
    print("Fetching data from: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        Map<String, dynamic> data;
        if (decoded is Map) {
           data = (decoded.containsKey('data') && decoded['data'] is Map) 
               ? decoded['data'] 
               : decoded;
        } else {
           throw Exception('Format data surah tidak dikenali');
        }
        return Surah.fromJson(data);
      } else {
        throw Exception('Gagal mengambil detail Surah $id. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching SurahDetail $id: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getJuzList() async {
    final url = '${ApiConfig.baseUrl}/quran/juz';
    print("Fetching data from: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map) {
          return (decoded['data'] ?? decoded['juz'] ?? []) as List<dynamic>;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil daftar Juz. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching JuzList: $e");
      rethrow;
    }
  }

  static Future<List<Ayat>> getJuzDetail(int id) async {
    final url = '${ApiConfig.baseUrl}/quran/juz/$id';
    print("Fetching data from: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          // Check direct keys first
          if (decoded['ayat'] is List) {
             data = decoded['ayat'];
          } else if (decoded['juz'] is List) {
             data = decoded['juz'];
          } else if (decoded['data'] is List) {
             data = decoded['data'];
          } else if (decoded['data'] is Map) {
             // API like Alquran Cloud wraps in "data": {"ayahs": [ ... ] }
             final mapData = decoded['data'] as Map;
             data = mapData['ayahs'] ?? mapData['ayat'] ?? [];
          }
        }
        return data.map((json) => Ayat.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal mengambil detail Juz $id. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching JuzDetail $id: $e");
      rethrow;
    }
  }
}
