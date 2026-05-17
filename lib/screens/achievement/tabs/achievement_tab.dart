import 'package:flutter/material.dart';
import 'package:hifzh_master/models/achievement_model.dart';
import 'package:hifzh_master/services/gamification_service.dart';
import 'package:hifzh_master/screens/achievement/certificate_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hifzh_master/data/local_db/hive_manager.dart';

const _navy     = Color(0xFF0D2137);
const _navyCard = Color(0xFF122540);
const _gold     = Color(0xFFD4AF37);
const _teal     = Color(0xFF0D9488);

class AchievementTab extends StatefulWidget {
  const AchievementTab({super.key});
  @override
  State<AchievementTab> createState() => _AchievementTabState();
}

class _AchievementTabState extends State<AchievementTab> {
  UserStats? _stats;
  List<AchievementBadge> _badges = [];
  String _level = 'Pemula';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await GamificationService.calculateStats();
    final badges = GamificationService.getBadges(stats);
    final level = GamificationService.getLevel(stats);
    if (mounted) {
      setState(() {
        _stats = stats;
        _badges = badges;
        _level = level;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: _gold));
    }
    final s = _stats!;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // 1. SERTIFIKAT
        _CertificateCard(juzCompleted: s.juzCompleted),
        const SizedBox(height: 20),

        // 2. STATISTIK UTAMA
        _SectionLabel(title: 'Statistik Saya'),
        const SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: HiveManager.readingSessionBox.listenable(),
          builder: (ctx, Box rsBox, _) {
            return ValueListenableBuilder(
              valueListenable: HiveManager.hafalanHistoryBox.listenable(),
              builder: (ctx2, Box hhBox, __) {
                final lastRead = HiveManager.getLastReadSurah();
                final lastReadValue = lastRead['name'].toString().isEmpty
                    ? 'Belum ada'
                    : lastRead['name'].toString();
                
                final todayCount = HiveManager.getTodaySessions();
                final todayValue = '$todayCount sesi';

                return _StatsGrid(
                  stats: s, 
                  level: _level, 
                  lastRead: lastReadValue, 
                  todaySesi: todayValue
                );
              }
            );
          }
        ),
        const SizedBox(height: 20),

        // 3. PROGRESS HAFALAN
        _SectionLabel(title: 'Progress Hafalan'),
        const SizedBox(height: 10),
        _ProgressCard(title: 'Juz Selesai', completed: s.juzCompleted, total: 30, color: _teal),
        const SizedBox(height: 8),
        _ProgressCard(title: 'Surah Selesai', completed: s.surahCompleted, total: 114, color: _gold),
        const SizedBox(height: 20),

        // 4. LENCANA
        _SectionLabel(title: 'Lencana & Pencapaian'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.82,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: _badges.length,
          itemBuilder: (ctx, i) => _BadgeItem(badge: _badges[i]),
        ),
      ],
    );
  }
}

// ── Section Label ──
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(
              color: _gold, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ],
    );
  }
}

// ── Certificate Card ──
class _CertificateCard extends StatelessWidget {
  final int juzCompleted;
  const _CertificateCard({required this.juzCompleted});

  @override
  Widget build(BuildContext context) {
    final unlocked = juzCompleted >= 30;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: unlocked
              ? const [Color(0xFFB8860B), Color(0xFFD4AF37), Color(0xFFFFD700)]
              : const [Color(0xFF1a2a3a), Color(0xFF243448)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: unlocked ? _gold.withOpacity(0.6) : Colors.white12),
        boxShadow: [
          BoxShadow(
              color: unlocked
                  ? _gold.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, top: -10,
            child: Icon(Icons.workspace_premium_rounded,
                size: 110,
                color: Colors.white.withOpacity(unlocked ? 0.12 : 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    unlocked ? Icons.workspace_premium_rounded : Icons.lock_rounded,
                    color: unlocked ? const Color(0xFF0D2137) : Colors.white38,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    unlocked ? 'SERTIFIKAT HAFIZH' : 'Sertifikat Terkunci',
                    style: TextStyle(
                        color: unlocked
                            ? const Color(0xFF0D2137)
                            : Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                unlocked
                    ? 'Selamat! Anda telah menyelesaikan 30 Juz Al-Qur\'an.'
                    : 'Selesaikan 30 Juz untuk mendapatkan sertifikat eksklusif.',
                style: TextStyle(
                    color: unlocked
                        ? const Color(0xFF0D2137).withOpacity(0.75)
                        : Colors.white38,
                    fontSize: 12.5,
                    height: 1.4),
              ),
              const SizedBox(height: 14),
              if (!unlocked) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$juzCompleted / 30 Juz',
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    Text('${((juzCompleted / 30) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: juzCompleted / 30,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.white54),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CertificateScreen(isPreview: true)),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                    label: const Text('Preview Sertifikat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ] else
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CertificateScreen()),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Download Sertifikat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2137),
                    foregroundColor: _gold,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats Grid ──
class _StatsGrid extends StatelessWidget {
  final UserStats stats;
  final String level;
  final String lastRead;
  final String todaySesi;
  
  const _StatsGrid({
    required this.stats, 
    required this.level,
    required this.lastRead,
    required this.todaySesi,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Level', 'value': level, 'icon': Icons.military_tech_rounded, 'color': const Color(0xFF7C3AED)},
      {'label': 'Skor Tertinggi', 'value': '${stats.heighestScore}%', 'icon': Icons.emoji_events_rounded, 'color': _gold},
      {'label': 'Terakhir Dibaca', 'value': lastRead, 'icon': Icons.menu_book_rounded, 'color': const Color(0xFF3B82F6)},
      {'label': 'Progres Hari Ini', 'value': todaySesi, 'icon': Icons.timeline_rounded, 'color': _teal},
      {'label': 'Total Bintang', 'value': '${stats.totalStars} ⭐', 'icon': Icons.star_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Total Sesi', 'value': '${stats.totalSessions}x', 'icon': Icons.fitness_center_rounded, 'color': Colors.pinkAccent},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: items.map((item) {
        final color = item['color'] as Color;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _navyCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['value'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(item['label'] as String,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Progress Card ──
class _ProgressCard extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  final Color color;
  const _ProgressCard({
    required this.title,
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? completed / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Text('$completed / $total',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(pct * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Badge Item ──
class _BadgeItem extends StatelessWidget {
  final AchievementBadge badge;
  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (badge.id.contains('streak')) icon = Icons.local_fire_department_rounded;
    else if (badge.id.contains('score')) icon = Icons.emoji_events_rounded;
    else if (badge.id.contains('juz')) icon = Icons.menu_book_rounded;
    else icon = Icons.star_rounded;

    final color = badge.isUnlocked ? _gold : Colors.white24;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (badge.isUnlocked ? _gold : Colors.white)
                .withOpacity(badge.isUnlocked ? 0.12 : 0.04),
            border: Border.all(
                color: color.withOpacity(badge.isUnlocked ? 0.5 : 0.2),
                width: 1.5),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 7),
        Text(badge.title,
            style: TextStyle(
                color: badge.isUnlocked ? Colors.white : Colors.white30,
                fontWeight: FontWeight.bold,
                fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
