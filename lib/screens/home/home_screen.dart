// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Import service yang dibutuhkan
import '../../services/audio_service.dart';
import '../../services/speech_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil instance service dari Provider
    final audio = Provider.of<AudioService>(context, listen: false);
    final speech = Provider.of<SpeechService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Hifzh Master'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang di Aplikasi Hifzh Master!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Audio
              ElevatedButton.icon(
                onPressed: () async {
                  await audio.playSound();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memutar audio...')),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Putar Suara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  await audio.stopSound();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Audio dihentikan')),
                  );
                },
                icon: const Icon(Icons.stop),
                label: const Text('Hentikan Suara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Speech to Text
              ElevatedButton.icon(
                onPressed: () async {
                  await speech.startListening();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mendengarkan suara...')),
                  );
                },
                icon: const Icon(Icons.mic),
                label: const Text('Mulai Mendengarkan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  speech.stopListening();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhenti mendengarkan')),
                  );
                },
                icon: const Icon(Icons.mic_off),
                label: const Text('Berhenti Mendengarkan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
