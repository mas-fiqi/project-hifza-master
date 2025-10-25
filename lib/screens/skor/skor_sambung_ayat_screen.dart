// ============================================
// 📄 File: lib/screens/skor/skor_sambung_ayat_screen.dart
// --------------------------------------------
// Halaman ini menampilkan skor hasil ujian sambung ayat.
// Misalnya ketika pengguna dites untuk melanjutkan ayat berikutnya.
// ============================================

import 'package:flutter/material.dart';

class SkorSambungAyatScreen extends StatelessWidget {
  const SkorSambungAyatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Contoh data skor sambung ayat
    final List<Map<String, dynamic>> skorSambungAyat = [
      {'surah': 'Al-Kahfi', 'tanggal': '25 Okt 2025', 'nilai': 92},
      {'surah': 'Yasin', 'tanggal': '20 Okt 2025', 'nilai': 85},
      {'surah': 'Ar-Rahman', 'tanggal': '15 Okt 2025', 'nilai': 90},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Sambung Ayat'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skorSambungAyat.length,
        itemBuilder: (context, index) {
          final skor = skorSambungAyat[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                child: const Icon(Icons.auto_graph, color: Colors.blueAccent),
              ),
              title: Text(
                skor['surah'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Tanggal: ${skor['tanggal']}'),
              trailing: Text(
                '${skor['nilai']}',
                style: const TextStyle(
                  color: Colors.blueAccent,
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
