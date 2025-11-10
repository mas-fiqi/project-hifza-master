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
  }

  // --- Helper untuk akses box ---
  // gunakan tipe generik List<dynamic> supaya aman saat mengambil value dari box
  static Box<List<dynamic>> get searchBox => Hive.box<List<dynamic>>(boxSearchHistory);
  static Box get userProgressBox => Hive.box(boxUserProgress);
  static Box get settingsBox => Hive.box(boxSettings);

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
