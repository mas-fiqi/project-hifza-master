// lib/data/local_db/hive_manager.dart
import 'package:hive_flutter/hive_flutter.dart';

/// HiveManager
/// - inisialisasi Hive
/// - register adapter (jika ada)
/// - open box yang dibutuhkan
/// - helper getter untuk box umum
class HiveManager {
  // Nama box
  static const String boxSearchHistory = 'search_history';
  static const String boxUserProgress = 'user_progress';
  static const String boxSettings = 'app_settings';
  static const String boxHafalanHistory = 'hafalan_history';
  static const String boxReadingSession = 'reading_session';

  /// Panggil di main() satu kali sebelum runApp()
  static Future<void> init() async {
    await Hive.initFlutter();

    // Jika ada TypeAdapters untuk model custom, register di sini:
    // Hive.registerAdapter(SurahModelAdapter());
    // Hive.registerAdapter(UserProgressAdapter());

    // Buka box yang dibutuhkan
    // Untuk boxSearchHistory kita simpan List<String> -> openBox<List>
    await Hive.openBox<List>(boxSearchHistory);

    // Box lain bisa dibuka tanpa tipe spesifik (dynamic) jika isinya bervariasi
    await Hive.openBox(boxUserProgress);
    await Hive.openBox(boxSettings);
    await Hive.openBox(boxHafalanHistory);
    await Hive.openBox(boxReadingSession);
  }

  // --- Helper untuk akses box ---
  static Box<List<dynamic>> get searchBox => Hive.box<List<dynamic>>(boxSearchHistory);
  static Box get userProgressBox => Hive.box(boxUserProgress);
  static Box get settingsBox => Hive.box(boxSettings);
  static Box get hafalanHistoryBox => Hive.box(boxHafalanHistory);
  static Box get readingSessionBox => Hive.box(boxReadingSession);

  /// Simpan surah terakhir dibaca di Kitab Suci
  static Future<void> saveLastReadSurah(String surahName, int totalAyat) async {
    await readingSessionBox.put('last_surah_name', surahName);
    await readingSessionBox.put('last_surah_total_ayat', totalAyat);
  }

  /// Ambil data surah terakhir dibaca
  static Map<String, dynamic> getLastReadSurah() {
    return {
      'name': readingSessionBox.get('last_surah_name') as String? ?? '',
      'totalAyat': readingSessionBox.get('last_surah_total_ayat') as int? ?? 0,
    };
  }

  /// Hitung sesi tes hafalan yang sudah dilakukan hari ini
  static int getTodaySessions() {
    final today = DateTime.now();
    final items = getAllHafalanHistory();
    return items.where((item) {
      final dateStr = item['date'] as String? ?? '';
      if (dateStr.isEmpty) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
  }

  /// Simpan list ayat yang sudah dibaca per surah
  /// history[surah_id] = [1, 2, 3]
  static Future<void> saveSurahHistory(int surahId, List<int> ayats) async {
    await userProgressBox.put('history_$surahId', ayats);
  }

  /// Ambil riwayat ayat per surah
  static List<int> getSurahHistory(int surahId) {
    final List? stored = userProgressBox.get('history_$surahId') as List?;
    if (stored == null) return [];
    return List<int>.from(stored);
  }

  /// Simpan skor terakhir per surah
  static Future<void> saveSurahScore(int surahId, double score) async {
    await userProgressBox.put('score_$surahId', score);
  }

  /// Ambil skor terakhir per surah
  static double getSurahScore(int surahId) {
    return (userProgressBox.get('score_$surahId') ?? 0.0).toDouble();
  }

  /// Simpan Histori Hafalan Baru
  static Future<void> addHafalanHistory(Map<String, dynamic> historyData) async {
    await hafalanHistoryBox.add(historyData);
  }

  /// Ambil Semua Histori Hafalan
  static List<Map<String, dynamic>> getAllHafalanHistory() {
    return hafalanHistoryBox.values.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
  }

  /// Ambil riwayat (List<String>) — synchronous (tidak memakai await)
  static List<String> loadSearchHistory() {
    final List? stored = searchBox.get('history') as List?;
    if (stored == null) return <String>[];
    return stored.map((e) => e.toString()).toList();
  }

  /// Simpan riwayat pencarian
  static Future<void> saveSearchHistory(List<String> history) async {
    // simpan sebagai List<String> (Hive akan menyimpannya sebagai List<dynamic>)
    await searchBox.put('history', history);
  }

  /// Hapus semua history (opsional)
  static Future<void> clearSearchHistory() async {
    await searchBox.delete('history');
  }
}
