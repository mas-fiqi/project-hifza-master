// lib/screens/uji/seven_bit_screen.dart
import 'package:flutter/material.dart';

class SevenBitScreen extends StatelessWidget {
  const SevenBitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 7-Bit'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text(
              'Selamat datang di Modul 7-Bit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Di sini kamu dapat belajar 7-bit: latihan, teori singkat, dan kuis.',
              style: TextStyle(fontSize: 14),
            ),
            // Tambahkan widget latihan, list, dsb sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}
