import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hifzh_master/models/quran_model.dart';
import 'package:hifzh_master/data/juz_data.dart';
import 'package:hifzh_master/screens/quran/quran_reader_screen.dart';
import 'package:hifzh_master/widgets/quran_widgets.dart'; // New Widgets
import 'package:hifzh_master/services/quran_service.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data
  List<Surah> _surahList = [];
  List<Surah> _filteredSurahList = []; // For search results
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final list = await QuranService.getSurahList();
      
      setState(() {
        _surahList = list;
        _filteredSurahList = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Err load data: $e');
      setState(() {
        _loading = false;
        // Optionally show error to user
      });
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal memuat data dari server: $e')),
         );
      }
    }
  }

  void _filterSurah(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahList = _surahList;
      } else {
        final qText = query.toLowerCase().trim();
        final qNormalized = qText.replaceAll('jus', 'juz').replaceAll(' ', '');
        
        // Normalize transliteration differences (yasin vs ya sin, baqarah vs baqara)
        String normalizeString(String text) {
           return text.toLowerCase()
              .replaceAll(RegExp('[\\s\\-\\\'\\"’‘]'), '') // remove spaces, hyphens, quotes
              .replaceAll('ee', 'i')
              .replaceAll('oo', 'u')
              .replaceAll(RegExp(r'([aiueo])\1+'), r'$1') // remove double vowels (aa->a)
              .replaceAll(RegExp(r'ah$'), 'a'); // baqarah -> baqara
        }

        final cleanQ = normalizeString(qText);

        _filteredSurahList = _surahList.where((s) {
          final cleanNama = normalizeString(s.nama);
          final cleanLatin = normalizeString(s.namaLatin);

          final matchNama = cleanNama.contains(cleanQ);
          final matchLatin = cleanLatin.contains(cleanQ);
          final matchNomor = s.nomor.toString() == cleanQ;
          final matchJuz = s.juz.toString() == qText || 'juz${s.juz}' == qNormalized;
          return matchNama || matchLatin || matchNomor || matchJuz;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inject Error Renderer to show exact crash on screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(
              "CRASH: ${details.exception}\n\nSTACK: ${details.stack}",
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      );
    };

    // Islamic Navy & Gold Theme
    const bgColor = Color(0xFF0D2137);
    const accentColor = Color(0xFFD4AF37); // Gold
    const textColor = Colors.white;
    const cardColor = Color(0xFF122540);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: _searchCtrl.text.isNotEmpty 
           ? TextField(
               controller: _searchCtrl,
               autofocus: true,
               onChanged: _filterSurah,
               style: const TextStyle(color: Colors.white),
               decoration: InputDecoration(
                 hintText: 'Cari Surah...', 
                 hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                 border: InputBorder.none
               ),
               cursorColor: accentColor,
             )
           : const Text('Kitab Suci', style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
        actions: [
          IconButton(
            icon: Icon(_searchCtrl.text.isNotEmpty ? Icons.close : Icons.search),
            onPressed: () {
               setState(() {
                  if (_searchCtrl.text.isNotEmpty) {
                     _searchCtrl.clear();
                     _filterSurah('');
                  } else {
                     _searchCtrl.text = ' '; 
                     _searchCtrl.clear(); 
                  }
               });
            },
            color: Colors.white70,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: accentColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'SURAH'),
            Tab(text: 'JUZ'),
            Tab(text: 'BOOKMARK'),
          ],
        ),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: accentColor)) 
        : Column(
            children: [
              if (_searchCtrl.text.isEmpty) _buildIslamicBanner(accentColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSurahList(textColor, accentColor, cardColor),
                    _buildJuzList(textColor, accentColor, cardColor),
                    _buildBookmarkList(textColor, accentColor, cardColor),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildIslamicBanner(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF122540),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: Color(0xFFD4AF37),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Al-Qur\'an Al-Karim',
            style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(Color textColor, Color accentColor, Color cardColor) {
    return Column(
      children: [
        // "Terakhir Baca" Banner
        FutureBuilder(
          future: Hive.openBox('reading_session'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && Hive.isBoxOpen('reading_session')) {
              final box = Hive.box('reading_session');
              final lastSurahName = box.get('last_surah_name');
              final lastAyahRaw = box.get('last_ayah_index');
              final surahIndexRaw = box.get('last_surah_index');
              
              final int lastAyah = lastAyahRaw is int ? lastAyahRaw : 0;
              final int surahIndex = surahIndexRaw is int ? surahIndexRaw : -1;
              
              if (lastSurahName != null && surahIndex != -1 && surahIndex < _surahList.length) {
                return GestureDetector(
                   onTap: () {
                       Navigator.push(context, MaterialPageRoute(
                           builder: (_) => QuranReaderScreen(
                             surah: _surahList[surahIndex], 
                             startAyahIndex: lastAyah
                           )
                       ));
                   },
                   child: Container(
                     margin: const EdgeInsets.all(16),
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                        color: const Color(0xFF1A3A5C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                     ),
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: accentColor.withOpacity(0.1),
                             shape: BoxShape.circle,
                           ),
                           child: Icon(Icons.history_edu, color: accentColor, size: 24),
                         ),
                         const SizedBox(width: 16),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text("TERAKHIR DIBACA", style: TextStyle(color: accentColor.withOpacity(0.7), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 4),
                             Text("$lastSurahName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                             Text("Ayat ${lastAyah + 1}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                           ],
                         ),
                         const Spacer(),
                         Icon(Icons.play_circle_fill, color: accentColor, size: 32),
                       ],
                     ),
                   ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _filteredSurahList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final surah = _filteredSurahList[i];
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  leading: IslamicAyahSymbol(
                     number: surah.nomor, 
                     size: 40, 
                     color: accentColor,
                  ),
                  title: Text(surah.namaLatin, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("${surah.juz > 0 ? 'Juz ${surah.juz} • ' : ''}${surah.jumlahAyat} Ayat", 
                     style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: Text(
                    surah.nama, 
                    textAlign: TextAlign.right,
                    style: TextStyle(color: accentColor, fontSize: 20, fontFamily: 'Amiri', fontWeight: FontWeight.bold)
                  ),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJuzList(Color textColor, Color accentColor, Color cardColor) {
     return FutureBuilder<List<dynamic>>(
       future: QuranService.getJuzList(),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }
         
         if (snapshot.hasError) {
           return Center(child: Text('Error API: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
         }

         final juzList = snapshot.data ?? [];
         List<dynamic> filteredJuzList = juzList;
         if (_searchCtrl.text.isNotEmpty) {
           final q = _searchCtrl.text.toLowerCase().trim().replaceAll('jus', 'juz').replaceAll(' ', '');
           filteredJuzList = juzList.where((j) {
             int num = 0;
             if (j is Map) {
               num = int.tryParse((j['id'] ?? j['nomor'] ?? j['index']).toString()) ?? 0;
             }
             if (num == 0) return true; // Keep if parsed to 0 just in case
             return num.toString() == _searchCtrl.text.trim() || 'juz$num' == q;
           }).toList();
           
           // If 'juzList' wasn't structured properly, filter manually by index (1 to 30)
           if (juzList.isEmpty) {
              filteredJuzList = List.generate(30, (i) => i + 1).where((num) {
                 return num.toString() == _searchCtrl.text.trim() || 'juz$num' == q;
              }).toList();
           }
         }

         final int itemCount = filteredJuzList.isNotEmpty ? filteredJuzList.length : (_searchCtrl.text.isNotEmpty ? 0 : 30);

         if (itemCount == 0 && _searchCtrl.text.isNotEmpty) {
           return const Center(child: Text("Juz tidak ditemukan."));
         }

         return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
               // Fallback structure in case API returns unexpected format
               int juzNum = i + 1;
               if (juzList.isNotEmpty && i < juzList.length && juzList[i] is Map) {
                 final jMap = juzList[i] as Map;
                 final numRaw = jMap['id'] ?? jMap['nomor'] ?? jMap['index'] ?? (i + 1);
                 juzNum = numRaw is int ? numRaw : int.tryParse(numRaw.toString()) ?? (i + 1);
               }
               
               final startInfo = JuzData.getJuzLocation(juzNum);
               
               return Container(
                 decoration: BoxDecoration(
                   color: cardColor,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.white.withOpacity(0.05)),
                 ),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                   leading: Container(
                     width: 42, height: 42,
                     decoration: BoxDecoration(
                       color: accentColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: accentColor.withOpacity(0.2)),
                     ),
                     child: Center(
                       child: Text('$juzNum', style: TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.bold)),
                     ),
                   ),
                   title: Text('Juz $juzNum', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                   subtitle: Text("Mulai: $startInfo", style: TextStyle(color: Colors.white38, fontSize: 12)),
                   trailing: Icon(Icons.chevron_right, color: accentColor.withOpacity(0.4)),
                   onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => 
                         QuranReaderScreen(juzNumber: juzNum)
                      ));
                   },
                 ),
               );
            },
         );
       }
     );
  }

  Widget _buildBookmarkList(Color textColor, Color accentColor, Color cardColor) {
      return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(Icons.bookmark_outline_rounded, size: 80, color: Colors.white.withOpacity(0.05)),
              const SizedBox(height: 16),
              const Text("Belum ada bookmark", style: TextStyle(color: Colors.white24, fontSize: 13, letterSpacing: 1)),
           ],
         ),
      );
  }
}
