// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:hifzh_master/data/local_db/hive_manager.dart';
import 'package:hifzh_master/screens/search/search_overlay_screen.dart';
import 'package:hifzh_master/screens/quran/quran_list_screen.dart';
import 'package:hifzh_master/screens/uji/uji_suara_screen.dart';
import 'package:hifzh_master/screens/settings/settings_screen.dart';
import 'package:hifzh_master/screens/achievement/activity_achievement_screen.dart';

// ── Palet Tema Islami ──
const _navy     = Color(0xFF0D2137);
const _navyMid  = Color(0xFF1A3A5C);
const _navyCard = Color(0xFF122540);
const _gold     = Color(0xFFD4AF37);
const _teal     = Color(0xFF0D9488);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _incrementVisit(String route) async {
    try {
      if (!Hive.isBoxOpen('user_visits')) return;
      final box = Hive.box('user_visits');
      final cur = box.get(route) as int? ?? 0;
      await box.put(route, cur + 1);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Column(
        children: [
          // ── HERO HEADER ──
          _buildHeroHeader(context),

          // ── SCROLLABLE CONTENT ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Streak card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: const _StreakCard(),
                  ),
                  const SizedBox(height: 20),

                  // Menu fitur
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFeatureMenu(context),
                  ),
                  const SizedBox(height: 28),

                  // Panduan
                  _buildGuidanceSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO HEADER ──
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _navyMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row: avatar + salam + notif + gear
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _gold.withOpacity(0.15),
                    child: const Icon(Icons.person_rounded,
                        size: 24, color: _gold),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assalamu\'alaikum!',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 1),
                        Text('Semoga harimu penuh berkah ✨',
                            style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white54)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    icon: const Icon(Icons.settings_rounded,
                        color: Colors.white54, size: 22),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── KALIGRAFI AYAT ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: _gold.withOpacity(0.35), width: 1),
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.03),
              ),
              child: Column(
                children: [
                  const Text(
                    'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        color: _gold,
                        height: 1.6),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"Dan bacalah Al-Qur\'an dengan perlahan-lahan." (QS. Al-Muzzammil: 4)',
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

            // ── ORNAMENTAL DIVIDER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: Container(height: 1, color: _gold.withOpacity(0.25))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('❖',
                        style: TextStyle(
                            color: _gold.withOpacity(0.6),
                            fontSize: 13)),
                  ),
                  Expanded(child: Container(height: 1, color: _gold.withOpacity(0.25))),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── LIVE INFO BOXES ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder(
                valueListenable: HiveManager.readingSessionBox.listenable(),
                builder: (ctx, Box rsBox, _) {
                  return ValueListenableBuilder(
                    valueListenable:
                        HiveManager.hafalanHistoryBox.listenable(),
                    builder: (ctx2, Box hhBox, __) {
                      final lastRead = HiveManager.getLastReadSurah();
                      final surahName = lastRead['name'] as String;
                      final totalAyat = lastRead['totalAyat'] as int;
                      final lastReadValue = surahName.isEmpty
                          ? 'Belum ada bacaan'
                          : '$surahName · $totalAyat ayat';
                      final todayCount = HiveManager.getTodaySessions();
                      final todayValue = todayCount == 0
                          ? 'Belum ada sesi'
                          : '$todayCount sesi hari ini';

                      return Row(
                        children: [
                          _InfoBox(
                            label: 'Terakhir Dibaca',
                            value: lastReadValue,
                            icon: Icons.menu_book_rounded,
                            accentColor: _gold,
                          ),
                          const SizedBox(width: 10),
                          _InfoBox(
                            label: 'Progres Hari Ini',
                            value: todayValue,
                            icon: Icons.timeline_rounded,
                            accentColor: _teal,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SearchOverlayScreen())),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gold.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: Colors.white.withOpacity(0.4), size: 20),
                      const SizedBox(width: 10),
                      Text('Cari Surah, Ayat, atau Juz...',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 13.5)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FEATURE MENU ──
  Widget _buildFeatureMenu(BuildContext context) {
    return Column(
      children: [
        // Label section
        Row(
          children: [
            Container(
              width: 3, height: 18,
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Menu Utama',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ],
        ),
        const SizedBox(height: 14),

        // 2-column quick menu
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                title: 'Tes Bacaan',
                subtitle: 'Juz & Surah',
                icon: Icons.mic_rounded,
                gradientColors: const [_teal, Color(0xFF0369A1)],
                onTap: () {
                  _incrementVisit('/uji_suara');
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const UjiSuaraScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                title: 'Kitab Suci',
                subtitle: 'Baca Al-Qur\'an',
                icon: Icons.auto_stories_rounded,
                gradientColors: const [Color(0xFFD97706), Color(0xFFEA580C)],
                onTap: () {
                  _incrementVisit('/quran_list');
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const QuranListScreen()));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Full-width achievement
        _FeatureCardWide(
          title: 'Aktivitas & Prestasi',
          subtitle: 'Lihat progres, lencana & sertifikat hafizh',
          icon: Icons.emoji_events_rounded,
          accentColor: _gold,
          onTap: () {
            _incrementVisit('/skor_hafalan');
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ActivityAchievementScreen()));
          },
        ),
      ],
    );
  }

  // ── GUIDANCE SECTION ──
  Widget _buildGuidanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Container(
                width: 3, height: 18,
                decoration: BoxDecoration(
                    color: _gold, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              const Text('Cara Menggunakan Aplikasi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
        ),
        SizedBox(
          height: 195,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 8),
            children: const [
              _GuidanceCard(
                title: 'Cara Pakai Tes Bacaan',
                icon: Icons.mic_rounded,
                color: _teal,
                steps: [
                  '1️⃣ Buka menu Tes Bacaan.',
                  '2️⃣ Pilih Juz atau Surah.',
                  '3️⃣ Tekan 🎙️ lalu baca ayat.',
                  '4️⃣ Hijau = benar, Merah = salah.',
                ],
              ),
              SizedBox(width: 12),
              _GuidanceCard(
                title: 'Cara Pakai Kitab Suci',
                icon: Icons.auto_stories_rounded,
                color: Color(0xFFD97706),
                steps: [
                  '1️⃣ Buka menu Kitab Suci.',
                  '2️⃣ Pilih Surah atau Juz.',
                  '3️⃣ Tap ayat untuk tandai posisi.',
                  '4️⃣ Tap 🎙️ untuk evaluasi suara.',
                ],
              ),
              SizedBox(width: 12),
              _GuidanceCard(
                title: 'Cara Mencari Surah/Ayat',
                icon: Icons.search_rounded,
                color: Color(0xFF7C3AED),
                steps: [
                  '1️⃣ Ketuk kolom pencarian atas.',
                  '2️⃣ Ketik nama/nomor surah.',
                  '3️⃣ Ketik "juz 30" untuk cari juz.',
                  '4️⃣ Ketuk hasil untuk membuka.',
                ],
              ),
              SizedBox(width: 12),
              _GuidanceCard(
                title: 'Progres & Lencana',
                icon: Icons.emoji_events_rounded,
                color: _gold,
                steps: [
                  '1️⃣ Buka Aktivitas & Prestasi.',
                  '2️⃣ Lihat riwayat tes & skor.',
                  '3️⃣ Kumpulkan lencana hafalan.',
                  '4️⃣ Selesaikan 30 Juz → Sertifikat!',
                ],
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════
// WIDGETS
// ══════════════════════════════════

// ── Streak Card ──
class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Sab','Min','Sen','Sel','Rab','Kam','Jum'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Flame + Hari
          Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withOpacity(0.1),
                  border: Border.all(color: _gold.withOpacity(0.35), width: 1.5),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: _gold, size: 24),
              ),
              const SizedBox(height: 6),
              const Text('0 Hari',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(width: 16),

          // Hari-hari minggu ini
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final isToday = i == 3; // Selasa contoh
                    return Column(
                      children: [
                        Text(dayNames[i],
                            style: TextStyle(
                                color: isToday
                                    ? Colors.white
                                    : Colors.white38,
                                fontSize: 9,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        const SizedBox(height: 5),
                        Transform.rotate(
                          angle: 0.785398,
                          child: Container(
                            width: 13, height: 13,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isToday
                                      ? _gold
                                      : Colors.white24,
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text('Streak Terpanjang · 0 Hari',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11.5)),
              ],
            ),
          ),

          const SizedBox(width: 10),
          // Ikon ke achievement
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ActivityAchievementScreen())),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: _gold, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Box ──
class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature Card (2-col) ──
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Text(subtitle,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Feature Card Wide ──
class _FeatureCardWide extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _FeatureCardWide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _navyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border:
                    Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: accentColor.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Guidance Card ──
class _GuidanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> steps;

  const _GuidanceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.steps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(s,
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.35)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
