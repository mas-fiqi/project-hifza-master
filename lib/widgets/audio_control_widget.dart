// lib/widgets/audio_control_widget.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AyatAudioPlayer extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const AyatAudioPlayer({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  State<AyatAudioPlayer> createState() => _AyatAudioPlayerState();
}

class _AyatAudioPlayerState extends State<AyatAudioPlayer>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _loading = false;

  static const _bgColor  = Color(0xFF0B1423);
  static const _cardColor = Color(0xFF152238);
  static const _gold     = Color(0xFFE5C07B);
  static const _teal     = Color(0xFF2DD4BF);
  static const _textGray = Color(0xFF94A3B8);

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = Duration.zero);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  String get _audioUrl {
    final s = widget.surahNumber.toString().padLeft(3, '0');
    final a = widget.ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
  }

  Future<void> _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      setState(() => _loading = true);
      try {
        await _player.play(UrlSource(_audioUrl));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memuat audio. Periksa koneksi internet.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Judul
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.headphones_rounded, color: _gold, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Murattal Ayat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Surah ${widget.surahNumber} · Ayat ${widget.ayahNumber}',
                    style: const TextStyle(color: _textGray, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Reciter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _teal.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_rounded, color: _teal, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'Sheikh Mishary Rashid Alafasy',
                  style: TextStyle(color: _textGray, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Progress bar
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: _gold,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: _gold,
                  overlayColor: _gold.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) async {
                    final pos = Duration(
                      milliseconds: (v * _duration.inMilliseconds).round(),
                    );
                    await _player.seek(pos);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(_position),
                        style: const TextStyle(color: _textGray, fontSize: 11)),
                    Text(_fmt(_duration),
                        style: const TextStyle(color: _textGray, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Kontrol utama
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Restart
              IconButton(
                onPressed: () async {
                  await _player.seek(Duration.zero);
                },
                icon: const Icon(Icons.replay_rounded, color: Colors.white54, size: 28),
              ),
              const SizedBox(width: 20),

              // Play / Pause button
              ScaleTransition(
                scale: isPlaying ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _loading ? null : _togglePlay,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5C07B), Color(0xFFD4A017)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.black54, strokeWidth: 2)
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.black87,
                            size: 38,
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Stop
              IconButton(
                onPressed: () async {
                  await _player.stop();
                  setState(() => _position = Duration.zero);
                },
                icon: const Icon(Icons.stop_rounded, color: Colors.white54, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
