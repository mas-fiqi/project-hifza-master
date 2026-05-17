// lib/widgets/quran_widgets.dart
import 'package:flutter/material.dart';

// ── Palet Warna Global ────────────────────────────────────────────────────────
class QColors {
  static const bg      = Color(0xFF0B1423);
  static const card    = Color(0xFF152238);
  static const gold    = Color(0xFFE5C07B);
  static const teal    = Color(0xFF2DD4BF);
  static const slate   = Color(0xFF94A3B8);
  static const navy2   = Color(0xFF0F1E33);
}

// ── Nomor Ayat Bergaya Islami (Lingkaran Elegan) ─────────────────────────────
class IslamicAyahSymbol extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final Color textColor;

  const IslamicAyahSymbol({
    super.key,
    required this.number,
    this.size = 42,
    this.color = const Color(0xFFE5C07B),
    this.textColor = const Color(0xFFE5C07B),
  });

  String _toArabicNum(int num) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return num.toString().split('').map((e) => d[int.parse(e)]).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner ring
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.22),
                width: 0.6,
              ),
            ),
          ),
          // Nomor Arab
          Text(
            _toArabicNum(number),
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: size * 0.40,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Dekoratif Surah ───────────────────────────────────────────────────
class SurahDecorativeHeader extends StatelessWidget {
  final String surahNameLatin;
  final String surahNameArabic;
  final int ayatCount;
  final String location;
  final int surahNumber;

  const SurahDecorativeHeader({
    super.key,
    required this.surahNameLatin,
    required this.surahNameArabic,
    required this.ayatCount,
    required this.location,
    required this.surahNumber,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE5C07B);
    const card = Color(0xFF152238);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Frame Utama ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withValues(alpha: 0.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Ornamen sudut dekoratif ──
              Positioned(
                top: 0, left: 0,
                child: _cornerOrnament(gold, false, false),
              ),
              Positioned(
                top: 0, right: 0,
                child: _cornerOrnament(gold, true, false),
              ),
              Positioned(
                bottom: 0, left: 0,
                child: _cornerOrnament(gold, false, true),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: _cornerOrnament(gold, true, true),
              ),

              // ── Konten ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // KIRI: Nama Latin & Nomor
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          surahNameLatin,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: gold.withValues(alpha: 0.3), width: 0.8),
                          ),
                          child: Text(
                            'Surat ke-$surahNumber',
                            style: TextStyle(
                              color: gold.withValues(alpha: 0.85),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TENGAH: Kaligrafi Arab + garis ornamen
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Garis ornamen atas
                        _ornamentalLine(gold),
                        const SizedBox(height: 6),
                        Text(
                          surahNameArabic,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 26,
                            color: gold,
                            height: 1.3,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Garis ornamen bawah
                        _ornamentalLine(gold),
                      ],
                    ),
                  ),

                  // KANAN: Lokasi & Ayat
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (location.contains('Mak')
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF2DD4BF))
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (location.contains('Mak')
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF2DD4BF))
                                  .withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: location.contains('Mak')
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF2DD4BF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$ayatCount Ayat',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Bismillah ──
        if (surahNumber != 1 && surahNumber != 9)
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 4),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 24,
                color: Colors.white,
                height: 1.8,
                shadows: [Shadow(color: Colors.white12, blurRadius: 3)],
              ),
            ),
          ),
      ],
    );
  }

  // Widget ornamen sudut kecil
  Widget _cornerOrnament(Color gold, bool flipX, bool flipY) {
    return Transform.scale(
      scaleX: flipX ? -1 : 1,
      scaleY: flipY ? -1 : 1,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(painter: _CornerPainter(gold)),
      ),
    );
  }

  // Garis ornamen horizontal tipis
  Widget _ornamentalLine(Color gold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(gold),
        Container(
          width: 28,
          height: 0.7,
          color: gold.withValues(alpha: 0.4),
        ),
        _diamond(gold),
        Container(
          width: 28,
          height: 0.7,
          color: gold.withValues(alpha: 0.4),
        ),
        _dot(gold),
      ],
    );
  }

  Widget _dot(Color gold) => Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gold.withValues(alpha: 0.5),
        ),
      );

  Widget _diamond(Color gold) => Transform.rotate(
        angle: 0.785398,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            border: Border.all(
              color: gold.withValues(alpha: 0.7),
              width: 0.8,
            ),
          ),
        ),
      );
}

// ── Painter ornamen sudut ───────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height), Offset(0, 4), paint);
    canvas.drawLine(Offset(0, 4), Offset(size.width, 4), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
