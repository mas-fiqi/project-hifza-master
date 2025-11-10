// lib/screens/home/home_screen.dart
// Versi layout baru: hero + overlapping search + grid menu + rekomendasi
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// package imports
import 'package:hifzh_master/screens/search/search_overlay_screen.dart';
import 'package:hifzh_master/screens/quran/quran_list_screen.dart';
import 'package:hifzh_master/screens/uji/uji_suara_screen.dart';
import 'package:hifzh_master/screens/skor/skor_hafalan_screen.dart';
import 'package:hifzh_master/screens/skor/skor_sambung_ayat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';

  final Map<String, Map<String, dynamic>> _featureMeta = {
    '/uji_suara': {
      'label': 'Uji Suara',
      'subtitle': 'Latihan membaca ayat',
      'color': Colors.blueAccent,
    },
    '/quran_list': {
      'label': 'Kitab Suci',
      'subtitle': 'Buka Al-Qur\'an',
      'color': Colors.orangeAccent,
    },
    '/skor_hafalan': {
      'label': 'Skor Hafalan',
      'subtitle': 'Progres hafalan',
      'color': Colors.green,
    },
    '/skor_sambung_ayat': {
      'label': 'Sambung Ayat',
      'subtitle': 'Nilai sambung ayat',
      'color': Colors.purpleAccent,
    },
  };

  List<String> _recommendationOrder = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendationOrder();
  }

  Future<void> _loadRecommendationOrder() async {
    try {
      if (Hive.isBoxOpen('user_visits')) {
        final box = Hive.box('user_visits');
        final Map<String, int> counts = {};
        for (var key in box.keys) {
          final val = box.get(key);
          if (val is int) counts[key.toString()] = val;
        }
        final ordered = _featureMeta.keys.toList();
        ordered.sort((a, b) {
          final ai = counts[a] ?? 0;
          final bi = counts[b] ?? 0;
          return bi.compareTo(ai);
        });
        setState(() => _recommendationOrder = ordered);
        return;
      }
    } catch (e) {
      debugPrint('Gagal baca user_visits: $e');
    }

    setState(() => _recommendationOrder = [
          '/uji_suara',
          '/quran_list',
          '/skor_hafalan',
          '/skor_sambung_ayat'
        ]);
  }

  Future<void> _incrementVisit(String route) async {
    try {
      if (!Hive.isBoxOpen('user_visits')) return;
      final box = Hive.box('user_visits');
      final cur = box.get(route) as int? ?? 0;
      await box.put(route, cur + 1);
      _loadRecommendationOrder();
    } catch (e) {
      debugPrint('Gagal simpan visit: $e');
    }
  }

  Color _shadowFromColor(Color c, [int alpha = 25]) =>
      Color.fromARGB(alpha, c.red, c.green, c.blue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HERO HEADER =====
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF60A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            child: const Icon(Icons.person,
                                size: 30, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Selamat Datang Belga 👋',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('Terus jaga hafalanmu hari ini',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white70)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Buka profil (implementasi nanti)')));
                            },
                            icon: const Icon(Icons.settings,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _SmallInfoBox(
                              label: 'Terakhir dibaca',
                              value: 'Al-Fatihah • 1',
                              icon: Icons.menu_book),
                          const SizedBox(width: 10),
                          _SmallInfoBox(
                              label: 'Progress hari ini',
                              value: '2/4 sesi',
                              icon: Icons.timeline),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -28,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SearchOverlayScreen())),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black54),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Cari Surah atau Ayat...',
                                  style: TextStyle(color: Colors.grey[600])),
                            ),
                            IconButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const SearchOverlayScreen())),
                              icon: const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // ===== BODY =====
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Latihan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FeatureTile(
                            width: itemWidth,
                            icon: Icons.mic,
                            title: 'Tes bacaan',
                            subtitle: 'Tingkatkan bacaan Al-Qur’an',
                            color: Colors.blueAccent,
                            onTap: () {
                              _incrementVisit('/uji_suara');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const UjiSuaraScreen()));
                            },
                            shadow: _shadowFromColor(Colors.blueAccent, 26),
                          ),
                          _FeatureTile(
                            width: itemWidth,
                            icon: Icons.menu_book,
                            title: 'Kitab Suci',
                            subtitle: 'Mari mampir dulu geratis kawanqu',
                            color: Colors.orangeAccent,
                            onTap: () {
                              _incrementVisit('/quran_list');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const QuranListScreen()));
                            },
                            shadow: _shadowFromColor(Colors.orangeAccent, 26),
                          ),
                          _FeatureTile(
                            width: itemWidth,
                            icon: Icons.assessment,
                            title: 'Poin tes bacaan',
                            subtitle: 'Hasil usaha',
                            color: Colors.green,
                            onTap: () {
                              _incrementVisit('/skor_hafalan');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SkorHafalanScreen()));
                            },
                            shadow: _shadowFromColor(Colors.green, 26),
                          ),
                          _FeatureTile(
                            width: itemWidth,
                            icon: Icons.stacked_line_chart,
                            title: 'Poin tes tulis',
                            subtitle: 'Hasil latihan',
                            color: Colors.purpleAccent,
                            onTap: () {
                              _incrementVisit('/skor_sambung_ayat');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          SkorSambungAyatScreen()));
                            },
                            shadow: _shadowFromColor(Colors.purpleAccent, 26),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sering Dikunjungi',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Lihat semua (implementasi nanti)')));
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendationOrder.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final route = _recommendationOrder[index];
                          final meta = _featureMeta[route]!;
                          final Color c = meta['color'] as Color;
                          return _RecommendationCard(
                            label: meta['label'] as String,
                            subtitle: meta['subtitle'] as String,
                            color: c,
                            onTap: () {
                              _incrementVisit(route);
                              if (route == '/uji_suara') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const UjiSuaraScreen()));
                              } else if (route == '/quran_list') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const QuranListScreen()));
                              } else if (route == '/skor_hafalan') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            SkorHafalanScreen()));
                              } else if (route == '/skor_sambung_ayat') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            SkorSambungAyatScreen()));
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Text(
                        'Tip: Coba latihan 10 menit setiap hari untuk meningkatkan konsistensi hafalan.',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SmallInfoBox(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.14),
                child: Icon(icon, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Color shadow;

  const _FeatureTile(
      {required this.width,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap,
      required this.shadow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Color.fromARGB(28, color.red, color.green, color.blue),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _RecommendationCard(
      {required this.label,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shadow = Color.fromARGB(28, color.red, color.green, color.blue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: 26,
                backgroundColor:
                    Color.fromARGB(28, color.red, color.green, color.blue),
                child: Icon(Icons.star, color: color)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
