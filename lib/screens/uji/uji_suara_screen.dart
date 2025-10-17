import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class UjiSuaraScreen extends StatefulWidget {
  const UjiSuaraScreen({super.key});

  @override
  State<UjiSuaraScreen> createState() => _UjiSuaraScreenState();
}

class _UjiSuaraScreenState extends State<UjiSuaraScreen> {
  // 🔹 Instance speech recognizer dari plugin speech_to_text
  late stt.SpeechToText _speech;

  // 🔹 Variabel untuk menandai status sedang mendengarkan
  bool _isListening = false;

  // 🔹 Hasil teks dari suara pengguna
  String _recognizedText = '';

  // 🔹 Target hafalan yang seharusnya dibaca (bisa dari DB atau file JSON)
  final String _targetText = 'Bismillahirrahmanirrahim';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // ================================
  // 🔹 FUNGSI: Memulai / menghentikan pendengaran
  // ================================
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Status: $status'),
        onError: (error) => debugPrint('Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          localeId: 'id_ID', // Gunakan bahasa Indonesia
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // ================================
  // 🔹 FUNGSI: Membandingkan teks hafalan dan hasil suara
  // ================================
  List<TextSpan> _compareText(String target, String spoken) {
    final targetWords = target.split(' ');
    final spokenWords = spoken.split(' ');

    List<TextSpan> spans = [];

    for (int i = 0; i < targetWords.length; i++) {
      final word = targetWords[i];
      // Jika spoken lebih pendek, sisanya dianggap belum dibaca
      final spokenWord = i < spokenWords.length ? spokenWords[i] : '';

      // Jika sama → teks hijau, jika beda → teks merah
      final color = word.toLowerCase() == spokenWord.toLowerCase()
          ? Colors.green
          : Colors.red;

      spans.add(
        TextSpan(
          text: '$word ',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontFamily: 'Amiri',
          ),
        ),
      );
    }

    return spans;
  }

  // ================================
  // 🔹 UI
  // ================================
  @override
  Widget build(BuildContext context) {
    final textSpans = _compareText(_targetText, _recognizedText);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Hafalan Suara'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎧 Ikon mikrofon
            Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isListening ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),

            // 🎙️ Keterangan status
            Text(
              _isListening
                  ? 'Sedang mendengarkan bacaanmu...'
                  : 'Tekan tombol di bawah untuk mulai uji hafalan',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 📖 Teks target ayat
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: textSpans,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🔘 Tombol mulai/berhenti
            ElevatedButton.icon(
              onPressed: _listen,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(
                _isListening ? 'Berhenti Mendengarkan' : 'Mulai Uji Suara',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Hasil suara yang ditangkap (untuk debugging)
            if (_recognizedText.isNotEmpty)
              Text(
                'Teks dikenali: $_recognizedText',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }
}
