// lib/services/gamification_service.dart
import 'package:hifzh_master/models/achievement_model.dart';
import 'package:hifzh_master/data/local_db/hive_manager.dart';

class GamificationService {
  
  // Calculate Stats from History Box
  static Future<UserStats> calculateStats() async {
     final items = HiveManager.getAllHafalanHistory();
     
     int totalSessions = items.length;
     int totalScore = 0;
     int heighest = 0;
     int totalStars = 0;
     Set<int> distinctSurahs = {};
     Set<int> distinctJuz = {}; // To estimate juz completion if any
     
     for (var item in items) {
        final rawScore = item['score'];
        int score = 0;
        if (rawScore is int) score = rawScore;
        else if (rawScore is double) score = rawScore.toInt();
        
        totalScore += score;
        if (score > heighest) heighest = score;
        
        int stars = 0;
        if (score >= 85) stars = 3;
        else if (score >= 70) stars = 2;
        else if (score >= 50) stars = 1;
        totalStars += stars;
        
        // Cek Kelulusan Surah (Misal nilai KKM = 70)
        final surahId = item['surahId'];
        if (surahId != null && surahId is int && score >= 70) {
            distinctSurahs.add(surahId);
        }

        // Jika ke depan ada fitur mode Uji Juz:
        final surahName = item['surahName']?.toString() ?? "";
        if (surahName.toLowerCase().contains("juz") && score >= 70) {
            distinctJuz.add(surahId ?? 0);
        }
     }
     
     // Streak logic (Mock for now, or read from settings)
     int streak = 1; 
     
     return UserStats(
       totalSessions: totalSessions,
       totalScore: totalScore,
       heighestScore: heighest,
       totalStars: totalStars,
       juzCompleted: distinctJuz.length, 
       surahCompleted: distinctSurahs.length,
       streakDays: streak,
     );
  }

  static List<AchievementBadge> getBadges(UserStats stats) {
     return [
        AchievementBadge(
          id: 'streak_7', 
          title: 'Istiqomah 7 Hari', 
          description: 'Latihan rutin selama 7 hari', 
          iconAsset: '',
          isUnlocked: stats.totalSessions >= 7
        ),
        AchievementBadge(
          id: 'sessions_50', 
          title: 'Santri Rajin', 
          description: 'Menyelesaikan 50 uji hafalan', 
          iconAsset: '',
          isUnlocked: stats.totalSessions >= 50
        ),
        AchievementBadge(
          id: 'score_90', 
          title: 'Hafalan Mumtaz', 
          description: 'Mencapai akurasi sempurna (>90)', 
          iconAsset: '',
          isUnlocked: stats.heighestScore >= 90
        ),
        AchievementBadge(
          id: 'surah_1', 
          title: 'Mulai Menghafal', 
          description: 'Lulus 1 Surah penuh', 
          iconAsset: '',
          isUnlocked: stats.surahCompleted >= 1
        ),
        AchievementBadge(
          id: 'surah_37', 
          title: 'Hafal Sepertiga', 
          description: 'Menyelesaikan 37 Surah', 
          iconAsset: '',
          isUnlocked: stats.surahCompleted >= 37
        ),
        AchievementBadge(
          id: 'surah_114', 
          title: 'Khatam Surah', 
          description: 'Menyelesaikan seluruh 114 Surah', 
          iconAsset: '',
          isUnlocked: stats.surahCompleted >= 114
        ),
     ];
  }
  
  static String getLevel(UserStats stats) {
     if (stats.surahCompleted >= 114) return "Hafizh Khatam";
     if (stats.surahCompleted >= 50) return "Hafizh Menengah";
     if (stats.surahCompleted >= 10) return "Santri Teladan";
     if (stats.totalSessions >= 5) return "Santri Aktif";
     return "Pemula";
  }

  static Future<bool> isSurahUnlocked(int surahId) async {
    final unlocked = await getUnlockedSurahs();
    return unlocked.contains(surahId);
  }

  static Future<bool> isJuzUnlocked(int juzNumber) async {
    final unlocked = await getUnlockedJuz();
    return unlocked.contains(juzNumber);
  }

  static Future<Set<int>> getUnlockedSurahs() async {
    final items = HiveManager.getAllHafalanHistory();
    Set<int> passedSurahs = {1}; // Al-Fatihah selalu buka
    
    // Juz 30 (78-114) selalu terbuka
    for (int i = 78; i <= 114; i++) {
      passedSurahs.add(i);
    }

    // Ambil surah yang sudah dapet bintang 3 (score >= 85)
    Set<int> masteredSurahs = {};
    for (var item in items) {
      final id = item['surahId'];
      final score = item['score'] ?? 0;
      final name = item['surahName']?.toString().toLowerCase() ?? "";
      if (id != null && score >= 85 && !name.contains("juz")) {
        masteredSurahs.add(id);
      }
    }

    // Buka surah n jika n-1 sudah mastered
    for (int i = 2; i <= 77; i++) {
      if (masteredSurahs.contains(i - 1)) {
        passedSurahs.add(i);
      }
    }

    return passedSurahs;
  }

  static Future<Set<int>> getUnlockedJuz() async {
    final items = HiveManager.getAllHafalanHistory();
    Set<int> passedJuz = {1}; // Juz 1 selalu buka
    
    // Ambil juz yang sudah dapet bintang 3
    Set<int> masteredJuz = {};
    for (var item in items) {
      final name = item['surahName']?.toString().toLowerCase() ?? "";
      final score = item['score'] ?? 0;
      if (name.contains("juz") && score >= 85) {
        // Ekstrak nomor juz dari "juz X"
        final parts = name.split(" ");
        if (parts.length >= 2) {
          final num = int.tryParse(parts[1]);
          if (num != null) masteredJuz.add(num);
        }
      }
    }

    // Buka juz n jika n-1 sudah mastered
    for (int i = 2; i <= 30; i++) {
      if (masteredJuz.contains(i - 1)) {
        passedJuz.add(i);
      }
    }

    return passedJuz;
  }
}
