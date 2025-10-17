import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> startListening() async {
    await _speech.initialize();
    await _speech.listen(onResult: (result) {
      print('Hasil: ${result.recognizedWords}');
    });
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
