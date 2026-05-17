import 'package:flutter/material.dart';
import 'package:hifzh_master/screens/uji/juz_test_screen.dart';
import 'package:hifzh_master/services/gamification_service.dart';

// Nama surah pertama di tiap juz (untuk label info)
const _juzFirstSurah = [
  'Al-Fatihah', 'Al-Baqarah', 'Al-Baqarah', "Ali 'Imran", "An-Nisa'",
  "An-Nisa'", "Al-Ma'idah", "Al-An'am", "Al-A'raf", "Al-Anfal",
  "At-Taubah", "Hud", "Yusuf", "Al-Hijr", "Al-Isra'",
  "Al-Kahf", "Al-Anbiya'", "Al-Mu'minun", "Al-Furqan", "An-Naml",
  "Al-Ankabut", "Al-Ahzab", "Ya Sin", "Az-Zumar", "Fussilat",
  "Al-Ahqaf", "Adh-Dhariyat", "Al-Mujadilah", "Al-Mulk", "An-Naba'",
];

// Jumlah surah di tiap juz (perkiraan)
const _juzSurahCount = [
  2,1,2,2,2, 2,2,2,2,2,
  2,2,3,2,2, 2,4,3,2,2,
  2,4,4,4,5, 5,8,10,16,37,
];

// Nomor Juz dalam bahasa Arab
const _juzArabicNames = [
  'الجزء الأوّل','الجزء الثاني','الجزء الثالث','الجزء الرابع','الجزء الخامس',
  'الجزء السادس','الجزء السابع','الجزء الثامن','الجزء التاسع','الجزء العاشر',
  'الجزء الحادي عشر','الجزء الثاني عشر','الجزء الثالث عشر','الجزء الرابع عشر','الجزء الخامس عشر',
  'الجزء السادس عشر','الجزء السابع عشر','الجزء الثامن عشر','الجزء التاسع عشر','الجزء العشرون',
  'الجزء الحادي والعشرون','الجزء الثاني والعشرون','الجزء الثالث والعشرون','الجزء الرابع والعشرون','الجزء الخامس والعشرون',
  'الجزء السادس والعشرون','الجزء السابع والعشرون','الجزء الثامن والعشرون','الجزء التاسع والعشرون','الجزء الثلاثون',
];

const _arabicNumerals = [
  '١','٢','٣','٤','٥','٦','٧','٨','٩','١٠',
  '١١','١٢','١٣','١٤','١٥','١٦','١٧','١٨','١٩','٢٠',
  '٢١','٢٢','٢٣','٢٤','٢٥','٢٦','٢٧','٢٨','٢٩','٣٠',
];

class JuzListScreen extends StatefulWidget {
  const JuzListScreen({super.key});

  @override
  State<JuzListScreen> createState() => _JuzListScreenState();
}

class _JuzListScreenState extends State<JuzListScreen> {
  Set<int> _unlockedJuz = {1}; // Default Juz 1
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlocked();
  }

  Future<void> _loadUnlocked() async {
    final unlocked = await GamificationService.getUnlockedJuz();
    if (mounted) {
      setState(() {
        _unlockedJuz = unlocked;
        _loading = false;
      });
    }
  }

  void _onJuzTap(BuildContext context, int juz) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => JuzTestScreen(initialJuz: juz)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2137), // Biru tua Islami
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO ISLAMI ──
          SliverToBoxAdapter(
            child: _IslamicHeader(),
          ),

          // ── LIST JUZ ──
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final juz = index + 1;
                    final isLocked = !_unlockedJuz.contains(juz);
                    return _JuzListTile(
                      juz: juz,
                      arabicName: _juzArabicNames[index],
                      arabicNum: _arabicNumerals[index],
                      firstSurah: _juzFirstSurah[index],
                      isLocked: isLocked,
                      onTap: isLocked ? null : () => _onJuzTap(context, juz),
                    );
                  },
                  childCount: 30,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── HEADER ISLAMI ──
class _IslamicHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // AppBar area
          SafeArea(
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
                    child: Text('Pilih Juz',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Kaligrafi Bismillah dekoratif
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.04),
            ),
            child: const Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                color: Color(0xFFD4AF37),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Dekorasi Al-Quran ikon + teks
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories_rounded,
                  color: Color(0xFFD4AF37), size: 18),
              const SizedBox(width: 8),
              Text('Al-Qur\'an · ٣٠ Juz · ١١٤ Surah',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 13)),
              const SizedBox(width: 8),
              const Icon(Icons.auto_stories_rounded,
                  color: Color(0xFFD4AF37), size: 18),
            ],
          ),

          const SizedBox(height: 16),

          // Garis ornamental
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(height: 1,
                      color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('❖',
                      style: TextStyle(
                          color: const Color(0xFFD4AF37).withOpacity(0.7),
                          fontSize: 14)),
                ),
                Expanded(
                  child: Container(height: 1,
                      color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── JUZ TILE ──
class _JuzListTile extends StatelessWidget {
  final int juz;
  final String arabicName;
  final String arabicNum;
  final String firstSurah;
  final bool isLocked;
  final VoidCallback? onTap;

  const _JuzListTile({
    required this.juz,
    required this.arabicName,
    required this.arabicNum,
    required this.firstSurah,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna aksen emas-hijau bergantian
    // Consistent Premium Gold
    const gold = Color(0xFFD4AF37);
    const accent = gold;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(16, 14, 20, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF122540),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked ? Colors.white10 : accent.withOpacity(0.22),
              width: 1,
            ),
            boxShadow: [
              if (!isLocked)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            children: [
              // Badge nomor Arab / Lock icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isLocked ? Colors.white24 : accent.withOpacity(0.5), 
                      width: 1.5),
                  color: isLocked ? Colors.white.withOpacity(0.05) : accent.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLocked)
                      const Icon(Icons.lock_rounded, color: Colors.white24, size: 18)
                    else ...[
                      Icon(Icons.menu_book_rounded,
                        color: accent, size: 14),
                      const SizedBox(height: 1),
                      Text(arabicNum,
                          style: TextStyle(
                              color: accent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Amiri')),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Konten teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Arab Juz
                    Text(arabicName,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.3)),
                    const SizedBox(height: 3),
                    Text('Dimulai dari $firstSurah',
                        style: TextStyle(
                            fontSize: 11.5, color: Colors.white.withOpacity(0.45))),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
