// lib/screens/quran/quran_reader_screen.dart
import 'package:flutter/material.dart';
import '/models/quran_model.dart';

class QuranReaderScreen extends StatelessWidget {
  final Surah surah;
  const QuranReaderScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${surah.namaLatin} — Surah ${surah.nomor}'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surah.ayat.length,
        itemBuilder: (context, idx) {
          final ay = surah.ayat[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade200, child: Text('${ay.index}', style: const TextStyle(fontSize: 12))),
                ),
                const SizedBox(height: 8),
                Text(
                  ay.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 26, height: 1.6),
                ),
                if (ay.translation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(ay.translation, style: const TextStyle(color: Colors.black87)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
