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
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
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
