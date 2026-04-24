// lib/screens/uji/result_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hifzh_master/screens/home/home_screen.dart';

class ResultScreen extends StatelessWidget {
  final String title; // "Juz 1" or "Al-Fatihah"
  final double score; // 0-100
  final bool isJuz; // true = show percentage, false = no percentage
  
  const ResultScreen({
    super.key, 
    required this.title, 
    required this.score, 
    this.isJuz = false
  });

  int get stars {
    if (score >= 85) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }
  
  void _saveResult() async {
    // Save to Hive for History
    try {
      if (!Hive.isBoxOpen('history')) await Hive.openBox('history');
      final box = Hive.box('history');
      await box.add({
        'title': title,
        'subtitle': isJuz ? 'Tes Juz' : 'Tes Surah',
        'points': score.toInt(),
        'stars': stars,
        'date': DateTime.now().toIso8601String(),
      });
    } catch(e) {
      debugPrint('Err saving: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock corrections
    final List<String> feedback = [
      'Ayat 2: Makhraj huruf "Ro" kurang tebal.',
      'Ayat 5: Panjang mad thabi\'i kurang pas.',
      'Kelancaran: Sangat baik, pertahankan!',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        title: const Text('Hasil Penilaian'),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 60,
                );
              }),
            ),
            const SizedBox(height: 24),
            
            // Score Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150, height: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: _scoreColor(score),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _scoreColor(score)),
                    ),
                    const Text('Poin', style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Percentage (Only for Juz)
            if (isJuz)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Progres Juz: 2.5%', 
                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),

            // Feedback / Corrections
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Catatan & Koreksi:', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: feedback.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Button Save
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _saveResult();
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const HomeScreen()), 
                    (route) => false
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Simpan & Kembali', 
                  style: TextStyle(fontSize: 18, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double s) {
    if (s >= 90) return Colors.green;
    if (s >= 70) return Colors.orange;
    return Colors.red;
  }
}
