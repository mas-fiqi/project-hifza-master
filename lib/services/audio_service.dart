import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final _player = AudioPlayer();

  Future<void> playSound() async {
    await _player.play(AssetSource('audio/surat_alf.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }
}
