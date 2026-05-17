import 'package:flutter/material.dart';
import 'package:hifzh_master/data/surah_data.dart';
import 'package:hifzh_master/screens/uji/juz_test_screen.dart';
import 'package:hifzh_master/services/gamification_service.dart';

class SurahSelectionScreen extends StatefulWidget {
  const SurahSelectionScreen({super.key});

  @override
  State<SurahSelectionScreen> createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends State<SurahSelectionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  Set<int> _unlockedSurahs = {1}; // Default Al-Fatihah
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlocked();
  }

  Future<void> _loadUnlocked() async {
    final unlocked = await GamificationService.getUnlockedSurahs();
    if (mounted) {
      setState(() {
        _unlockedSurahs = unlocked;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSurahTap(int nomor) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => JuzTestScreen(initialSurah: nomor)));
  }

  @override
  Widget build(BuildContext context) {
    final surahs = SurahData.allSurahNames;
    final surahsAr = SurahData.allSurahNamesArabic;
    final arabicNums = SurahData.arabicNumerals;

    final filtered = _query.isEmpty
        ? List.generate(surahs.length, (i) => i)
        : List.generate(surahs.length, (i) => i).where((i) =>
            surahs[i].toLowerCase().contains(_query.toLowerCase()) ||
            surahsAr[i].contains(_query) ||
            '${i + 1}'.contains(_query)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D2137),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HEADER ISLAMI ──
          SliverToBoxAdapter(child: _IslamicHeader(
            searchCtrl: _searchCtrl,
            query: _query,
            onSearch: (v) => setState(() => _query = v),
            onClear: () {
              _searchCtrl.clear();
              setState(() => _query = '');
            },
          )),

          // ── LIST SURAH ──
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final i = filtered[index];
                    final nomor = i + 1;
                    final ayat = i < SurahData.surahAyatCount.length ? SurahData.surahAyatCount[i] : 0;
                    final type = i < SurahData.surahType.length ? SurahData.surahType[i] : '';
                    final isLocked = !_unlockedSurahs.contains(nomor);

                    return _SurahTile(
                      nomor: nomor,
                      nameLatin: surahs[i],
                      nameArabic: surahsAr[i],
                      arabicNum: arabicNums[i],
                      ayatCount: ayat,
                      type: type,
                      isLocked: isLocked,
                      onTap: isLocked ? null : () => _onSurahTap(nomor),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── HEADER ──
class _IslamicHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String query;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const _IslamicHeader({
    required this.searchCtrl,
    required this.query,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // AppBar row
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
                    child: Text('Pilih Surah',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Bismillah
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.45), width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.03),
            ),
            child: const Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: Color(0xFFD4AF37),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Info baris
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories_rounded,
                  color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 7),
              Text('١١٤ Surah · Al-Qur\'an Al-Karim',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 12.5,
                      fontFamily: 'Amiri')),
              const SizedBox(width: 7),
              const Icon(Icons.auto_stories_rounded,
                  color: Color(0xFFD4AF37), size: 16),
            ],
          ),

          const SizedBox(height: 14),

          // Garis ornamental
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Container(
                    height: 1,
                    color: const Color(0xFFD4AF37).withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('❖', style: TextStyle(
                      color: const Color(0xFFD4AF37).withOpacity(0.7),
                      fontSize: 13)),
                ),
                Expanded(child: Container(
                    height: 1,
                    color: const Color(0xFFD4AF37).withOpacity(0.3))),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: Colors.white.withOpacity(0.5), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      cursorColor: const Color(0xFFD4AF37),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Cari nama surah atau نام السورة...',
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 13),
                        isDense: true,
                      ),
                      onChanged: onSearch,
                    ),
                  ),
                  if (query.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: Icon(Icons.close_rounded,
                          color: Colors.white.withOpacity(0.5), size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SURAH TILE ──
class _SurahTile extends StatelessWidget {
  final int nomor;
  final String nameLatin;
  final String nameArabic;
  final String arabicNum;
  final int ayatCount;
  final String type;
  final bool isLocked;
  final VoidCallback? onTap;

  const _SurahTile({
    required this.nomor,
    required this.nameLatin,
    required this.nameArabic,
    required this.arabicNum,
    required this.ayatCount,
    required this.type,
    required this.isLocked,
    this.onTap,
  });

  Color _accentColor(int n) {
    return const Color(0xFFD4AF37); // Consistent Gold for premium look
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(nomor);
    final isMakki = type == 'Makkiyyah';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF122540),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isLocked ? Colors.white10 : accent.withOpacity(0.2), 
                width: 1),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isLocked ? Colors.white24 : accent.withOpacity(0.45), 
                      width: 1.5),
                  color: isLocked ? Colors.white.withOpacity(0.05) : accent.withOpacity(0.08),
                ),
                child: Center(
                  child: isLocked 
                    ? const Icon(Icons.lock_rounded, color: Colors.white24, size: 18)
                    : Text(arabicNum,
                        style: TextStyle(
                            color: accent,
                            fontSize: arabicNum.length > 2 ? 11 : 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri')),
                ),
              ),

              const SizedBox(width: 14),

              // Konten tengah: nama Arab + Latin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // kanan (Arab)
                  children: [
                    // Nama Arab — besar & font Amiri
                    Text(
                      nameArabic,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Nama Latin kecil
                    Text(
                      nameLatin,
                      style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withOpacity(0.45)),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Info kanan: ayat + jenis + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isMakki
                              ? const Color(0xFFD97706)
                              : accent)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isMakki
                                ? const Color(0xFFD97706)
                                : accent)
                            .withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(type,
                        style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: isMakki
                                ? const Color(0xFFD97706)
                                : accent)),
                  ),
                  const SizedBox(height: 5),
                  Text('$ayatCount ayat',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4))),
                  const SizedBox(height: 3),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.25), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
