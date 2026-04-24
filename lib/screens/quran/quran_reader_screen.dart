// lib/screens/quran/quran_reader_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '/models/quran_model.dart';
import 'package:hifzh_master/widgets/quran_widgets.dart';
import 'package:hifzh_master/services/quran_service.dart';
import 'package:hifzh_master/data/surah_data.dart';
import 'package:hifzh_master/screens/recorder/recorder_widget.dart';
import 'package:hifzh_master/data/local_db/hive_manager.dart';
import 'package:hifzh_master/screens/uji/juz_test_screen.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah? surah;
  final int? juzNumber; 
  final int startAyahIndex; 

  const QuranReaderScreen({
    super.key, 
    this.surah, 
    this.juzNumber,
    this.startAyahIndex = 0
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  List<Ayat> _ayatList = [];
  bool _loading = true;
  String _error = '';

  // Theme Constants
  static const _navy     = Color(0xFF0D2137);
  static const _navyCard = Color(0xFF122540);
  static const _gold     = Color(0xFFD4AF37);
  static const _teal     = Color(0xFF0D9488);

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      if (widget.juzNumber != null) {
        final ayats = await QuranService.getJuzDetail(widget.juzNumber!);
        setState(() {
          _ayatList = ayats;
          _loading = false;
        });
      } else if (widget.surah != null) {
        final detailedSurah = await QuranService.getSurahDetail(widget.surah!.nomor);
        setState(() {
          _ayatList = detailedSurah.ayat;
          _loading = false;
        });
        await HiveManager.saveLastReadSurah(
          widget.surah!.namaLatin,
          widget.surah!.jumlahAyat,
        );
      }
      
      if (widget.startAyahIndex > 0 && mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
           if (mounted && _itemScrollController.isAttached) {
              _itemScrollController.jumpTo(index: widget.startAyahIndex + (widget.surah != null ? 1 : 0));
           }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveLastRead(int ayahIndex) async {
    if (widget.surah == null) return; 
    if (!Hive.isBoxOpen('reading_session')) await Hive.openBox('reading_session');
    var box = Hive.box('reading_session');
    await box.put('last_surah_name', widget.surah!.namaLatin);
    await box.put('last_surah_index', widget.surah!.nomor - 1); 
    await box.put('last_ayah_index', ayahIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isSurahMode = widget.surah != null;
    final title = isSurahMode ? widget.surah!.namaLatin : 'Juz ${widget.juzNumber}';

    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => 
                JuzTestScreen(
                  initialSurah: widget.surah?.nomor,
                  initialJuz: widget.juzNumber,
                )
              ));
            }, 
            icon: const Icon(Icons.quiz_rounded, color: _gold, size: 20), 
            label: const Text('UJIAN', style: TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 12))
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: _gold))
        : _error.isNotEmpty 
          ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
          : ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _ayatList.length + (isSurahMode ? 1 : 0),
              itemBuilder: (context, idx) {
                if (isSurahMode && idx == 0) {
                   return Container(
                     margin: const EdgeInsets.only(bottom: 24),
                     child: SurahDecorativeHeader(
                       surahNameLatin: widget.surah!.namaLatin,
                       surahNameArabic: widget.surah!.nama,
                       ayatCount: widget.surah!.jumlahAyat,
                       location: "Madaniyyah",
                       surahNumber: widget.surah!.nomor,
                     ),
                   );
                }
                
                final realIdx = isSurahMode ? idx - 1 : idx;
                final ay = _ayatList[realIdx]; 
                
                // Detect Surah transition for Juz Mode
                bool showHeader = false;
                if (!isSurahMode && ay.index == 1) {
                  showHeader = true;
                }

                return Column(
                  children: [
                    if (showHeader) _buildJuzSurahHeader(ay.surahId ?? 1, ay.surahName ?? "Surah"),
                    _buildAyatCard(ay),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildJuzSurahHeader(int surahId, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: SurahDecorativeHeader(
        surahNameLatin: name,
        surahNameArabic: SurahData.allSurahNamesArabic[surahId - 1],
        ayatCount: SurahData.surahAyatCount[surahId - 1],
        location: SurahData.surahType[surahId - 1],
        surahNumber: surahId
      ),
    );
  }

  Widget _buildAyatCard(Ayat ay) {
    return GestureDetector(
      onTap: () {
         _saveLastRead(ay.index - 1);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Tanda baca: Ayat ${ay.index}'),
             backgroundColor: _teal,
             duration: const Duration(seconds: 1)
           )
         );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 IslamicAyahSymbol(
                   number: ay.index,
                   size: 36,
                 ),
                 Row(
                   children: [
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: _gold, size: 20),
                        onPressed: () {
                           showModalBottomSheet(
                             context: context,
                             isScrollControlled: true,
                             backgroundColor: Colors.transparent,
                             builder: (_) => Padding(
                               padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                               child: RecorderWidget(
                                 surahNumber: widget.surah?.nomor ?? (ay.surahId ?? 1), 
                                 ayahNumber: ay.index,
                               ),
                             )
                           );
                        }
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.bookmark_border_rounded, color: Colors.white24, size: 20),
                   ],
                 )
              ],
            ),
            const SizedBox(height: 20),
            Text(
              ay.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri', fontSize: 28, height: 2.2, color: Colors.white
              ),
            ),
            if (ay.translation.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                ay.translation, 
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
