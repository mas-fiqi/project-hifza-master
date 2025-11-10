// ============================================
// 📄 File: lib/screens/skor/skor_hafalan_screen.dart
// --------------------------------------------
// Halaman ini menampilkan daftar skor hafalan pengguna.
// Setiap hafalan memiliki nilai (score), surah, dan ayat.
// ============================================

import 'package:flutter/material.dart';

class SkorHafalanScreen extends StatelessWidget {
  const SkorHafalanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Contoh data skor hafalan (bisa nanti diambil dari database)
    final List<Map<String, dynamic>> skorHafalan = [
      {'surah': 'Al-Fatihah', 'ayat': '1-7', 'nilai': 95},
      {'surah': 'Al-Baqarah', 'ayat': '1-5', 'nilai': 88},
      {'surah': 'An-Nas', 'ayat': '1-6', 'nilai': 100},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Hafalan'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),

      // 🔹 ListView untuk menampilkan daftar skor hafalan
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skorHafalan.length,
        itemBuilder: (context, index) {
          final skor = skorHafalan[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.2),
                child: const Icon(Icons.star, color: Colors.teal),
              ),
              title: Text(
                skor['surah'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Ayat ${skor['ayat']}'),
              trailing: Text(
                '${skor['nilai']}',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
