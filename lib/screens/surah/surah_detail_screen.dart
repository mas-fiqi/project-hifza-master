// lib/screens/surah/surah_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/surah_model.dart';

class SurahDetailScreen extends StatelessWidget {
  final SurahModel surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    // Tampilkan hanya field yang pasti ada di model umum:
    // nama, namaLatin, nomor, jumlahAyat, juz
    return Scaffold(
      appBar: AppBar(
        title: Text(surah.namaLatin),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            surah.nama,
            style: const TextStyle(fontSize: 30, fontFamily: 'Amiri'),
          ),
          const SizedBox(height: 8),
          Text(
            '${surah.jumlahAyat} ayat • Juz ${surah.juz} • Surah ke-${surah.nomor}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Jika model memiliki deskripsi, kamu bisa tambahkan; 
          // tapi supaya tidak error, kita tampilkan placeholder.
          const Text('Deskripsi singkat', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tidak ada deskripsi tersedia.', style: TextStyle(height: 1.4)),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // contoh: navigasi ke halaman latihan per kalimat (implementasi nanti)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mulai latihan untuk ${surah.namaLatin} (implementasi nanti)')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mulai latihan / dengarkan'),
          ),
        ]),
      ),
    );
  }
}
