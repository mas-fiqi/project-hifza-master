import 'package:flutter_test/flutter_test.dart';
import 'package:hifzh_master/services/gamification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  group('Gamification Logic Tests', () {
    setUpAll(() async {
      // Mock Hive path
      final tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      await Hive.openBox('hafalan_history');
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('Setup mock history', () async {
      final box = Hive.box('hafalan_history');
      await box.add({
        'surahId': 1,
        'surahName': 'Al-Fatihah',
        'score': 95,
        'date': DateTime.now().toIso8601String(),
      });
      await box.add({
        'surahId': 2,
        'surahName': 'Juz 1',
        'score': 88,
        'date': DateTime.now().toIso8601String(),
      });
    });

    test('isJuzUnlocked returns true for Juz 1', () async {
      final isUnlocked = await GamificationService.isJuzUnlocked(1);
      expect(isUnlocked, isTrue);
    });

    test('isJuzUnlocked returns false for Juz 2 if no history', () async {
      final isUnlocked = await GamificationService.isJuzUnlocked(2);
      expect(isUnlocked, isFalse);
    });

    test('isSurahUnlocked returns true for Al-Fatihah (1)', () async {
      final isUnlocked = await GamificationService.isSurahUnlocked(1);
      expect(isUnlocked, isTrue);
    });
  });
}
