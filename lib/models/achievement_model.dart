// lib/models/achievement_model.dart

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String iconAsset; // or IconData logic
  final bool isUnlocked;
  
  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.isUnlocked = false,
  });
}


class UserStats {
  final int totalSessions;
  final int totalScore;
  final int heighestScore;
  final int totalStars;
  final int juzCompleted; // out of 30
  final int surahCompleted; // out of 114
  final int streakDays;

  UserStats({
    this.totalSessions = 0,
    this.totalScore = 0,
    this.heighestScore = 0,
    this.totalStars = 0,
    this.juzCompleted = 0,
    this.surahCompleted = 0,
    this.streakDays = 0,
  });
}
