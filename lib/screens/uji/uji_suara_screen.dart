// lib/screens/uji/uji_suara_screen.dart
import 'package:flutter/material.dart';
import 'package:hifzh_master/screens/quran/juz_list_screen.dart';
import 'package:hifzh_master/screens/quran/surah_selection_screen.dart';

// ── Palet Islami (sama dengan home/juz/settings) ──
const _navy     = Color(0xFF0D2137);
const _navyMid  = Color(0xFF1A3A5C);
const _navyCard = Color(0xFF122540);
const _gold     = Color(0xFFD4AF37);
const _teal     = Color(0xFF0D9488);

class UjiSuaraScreen extends StatelessWidget {
  const UjiSuaraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO HEADER ──
          SliverToBoxAdapter(child: _buildHeader(context)),

          // ── BODY ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info banner
                _buildInfoBanner(),
                const SizedBox(height: 24),

                // Label pilih metode
                Row(
                  children: [
                    Container(width: 3, height: 18,
                        decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    const Text('Pilih Metode Tes',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Mulai dari Juz atau langsung per Surah',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12.5)),
                const SizedBox(height: 16),

                // CARD JUZ
                _TestModeCard(
                  title: 'Tes per Juz',
                  subtitle: 'Juz 1 sampai Juz 30',
                  description:
                      'Uji hafalan kamu dalam satu juz penuh secara berurutan.',
                  arabicLabel: 'جُزْء',
                  icon: Icons.auto_stories_rounded,
                  gradientColors: const [_teal, Color(0xFF0369A1)],
                  badgeText: '٣٠ Juz',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const JuzListScreen())),
                ),
                const SizedBox(height: 14),

                // CARD SURAH
                _TestModeCard(
                  title: 'Tes per Surah',
                  subtitle: 'Al-Fatihah sampai An-Nas',
                  description:
                      'Pilih surah spesifik dan tes hafalan ayat per ayat.',
                  arabicLabel: 'سُورَة',
                  icon: Icons.menu_book_rounded,
                  gradientColors: const [Color(0xFFD97706), Color(0xFFEA580C)],
                  badgeText: '١١٤ Surah',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SurahSelectionScreen())),
                ),

                const SizedBox(height: 28),

                // Cara kerja
                Row(
                  children: [
                    Container(width: 3, height: 18,
                        decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    const Text('Cara Kerja Sistem',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 14),

                _StepItem(
                    number: '১', color: _teal,
                    text: 'Tekan tombol mikrofon dan mulai membaca.'),
                _StepItem(
                    number: '২', color: const Color(0xFF0369A1),
                    text: 'AI mendeteksi bacaanmu secara real-time.'),
                _StepItem(
                    number: '৩', color: const Color(0xFFD97706),
                    text: 'Slot Hijau = benar, Merah = perlu diperbaiki.'),
                _StepItem(
                    number: '৪', color: const Color(0xFF7C3AED),
                    text: 'Lihat skor dan bintang setelah selesai!'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ISLAMI ──
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _navyMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Tes Bacaan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _teal.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.mic_rounded, color: _teal, size: 14),
                        SizedBox(width: 4),
                        Text('AI Hafizh', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── KALIGRAFI PENYEMANGAT ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.03),
            ),
            child: Column(
              children: [
                const Text(
                  'اِقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      color: _gold,
                      height: 1.7),
                ),
                const SizedBox(height: 5),
                Text(
                  '"Bacalah dengan menyebut nama Tuhanmu yang menciptakan." (QS. Al-Alaq: 1)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withOpacity(0.45),
                      height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Garis ornamental
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Container(height: 1, color: _gold.withOpacity(0.25))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('❖',
                      style: TextStyle(color: _gold.withOpacity(0.6), fontSize: 13)),
                ),
                Expanded(child: Container(height: 1, color: _gold.withOpacity(0.25))),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _teal.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _teal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tekan 🎙️ lalu bacalah dengan lantang dan jelas. Sistem AI akan otomatis mendeteksi dan menilai bacaanmu.',
              style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TEST MODE CARD ──
class _TestModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String arabicLabel;
  final IconData icon;
  final List<Color> gradientColors;
  final String badgeText;
  final VoidCallback onTap;

  const _TestModeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.arabicLabel,
    required this.icon,
    required this.gradientColors,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: gradientColors.first.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            // Icon + label Arab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 6),
                Text(arabicLabel,
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.2)),
              ],
            ),
            const SizedBox(width: 18),

            // Teks info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(badgeText,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11.5,
                          height: 1.4)),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54, size: 17),
          ],
        ),
      ),
    );
  }
}

// ── STEP ITEM ──
class _StepItem extends StatelessWidget {
  final String number;
  final Color color;
  final String text;

  const _StepItem({
    required this.number,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(number,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withOpacity(0.65),
                      height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}
