import 'package:flutter/foundation.dart'; // diperlukan untuk debugPrint
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> startListening() async {
    await _speech.initialize();
    await _speech.listen(onResult: (result) {
      // ambil teks dari result
      final recognizedText = result.recognizedWords;
      debugPrint('Speech recognized: $recognizedText');
    });
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
