// lib/screens/achievement/activity_achievement_screen.dart
import 'package:flutter/material.dart';
import 'package:hifzh_master/screens/achievement/tabs/activity_tab.dart';
import 'package:hifzh_master/screens/achievement/tabs/achievement_tab.dart';

const _navy     = Color(0xFF0D2137);
const _navyMid  = Color(0xFF1A3A5C);
const _gold     = Color(0xFFD4AF37);
const _teal     = Color(0xFF0D9488);

class ActivityAchievementScreen extends StatelessWidget {
  const ActivityAchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _navy,
        body: Column(
          children: [
            // ── HEADER ISLAMI ──
            Container(
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
                    // AppBar row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text('Aktivitas & Prestasi',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kaligrafi
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: _gold.withOpacity(0.35)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.03),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'وَقُلِ اعْمَلُوا فَسَيَرَى اللَّهُ عَمَلَكُمْ',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: _gold,
                                height: 1.6),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"Katakanlah: bekerjalah kamu, maka Allah akan melihat pekerjaanmu." (QS. At-Taubah: 105)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.4),
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Garis ornamental
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(child: Container(height: 1, color: _gold.withOpacity(0.25))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('❖',
                                style: TextStyle(
                                    color: _gold.withOpacity(0.6), fontSize: 13)),
                          ),
                          Expanded(child: Container(height: 1, color: _gold.withOpacity(0.25))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TabBar
                    TabBar(
                      indicatorColor: _gold,
                      labelColor: _gold,
                      unselectedLabelColor: Colors.white38,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      indicatorWeight: 2.5,
                      tabs: const [
                        Tab(text: 'AKTIVITAS'),
                        Tab(text: 'PRESTASI'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── TAB CONTENT ──
            const Expanded(
              child: TabBarView(
                children: [
                  ActivityTab(),
                  AchievementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
