// lib/screens/quran/quran_reader_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '/models/quran_model.dart';
import 'package:hifzh_master/widgets/quran_widgets.dart';
import 'package:hifzh_master/widgets/audio_control_widget.dart';
import 'package:hifzh_master/services/quran_service.dart';
import 'package:hifzh_master/data/surah_data.dart';
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
    this.startAyahIndex = 0,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen>
    with TickerProviderStateMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  List<Ayat> _ayatList = [];
  bool _loading = true;
  String _error = '';

  // Bookmark & active ayat
  final Set<int> _bookmarkedAyat = {};
  int _currentAyahIndex = 0; // currently focused ayah (0-based in _ayatList)

  // ── Theme ──────────────────────────────────────────────────────────────────
  static const _bgColor    = Color(0xFF0B1423);  // Deep Navy
  static const _cardColor  = Color(0xFF152238);  // Slightly lighter navy
  static const _gold       = Color(0xFFE5C07B);  // Soft Gold
  static const _teal       = Color(0xFF2DD4BF);  // Cyan / Teal
  static const _textGray   = Color(0xFF94A3B8);  // Slate 400

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _positionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions
        .where((p) => p.itemTrailingEdge > 0)
        .reduce((a, b) => a.itemTrailingEdge < b.itemTrailingEdge ? a : b);
    final isSurahMode = widget.surah != null;
    final rawIdx = first.index - (isSurahMode ? 1 : 0);
    if (rawIdx >= 0 && rawIdx < _ayatList.length && rawIdx != _currentAyahIndex) {
      setState(() => _currentAyahIndex = rawIdx);
    }
  }

  Future<void> _fetchDetail() async {
    try {
      if (widget.juzNumber != null) {
        final ayats = await QuranService.getJuzDetail(widget.juzNumber!);
        if (mounted) setState(() { _ayatList = ayats; _loading = false; });
      } else if (widget.surah != null) {
        final detailedSurah =
            await QuranService.getSurahDetail(widget.surah!.nomor);
        if (mounted) setState(() { _ayatList = detailedSurah.ayat; _loading = false; });
        await HiveManager.saveLastReadSurah(
          widget.surah!.namaLatin,
          widget.surah!.jumlahAyat,
        );
      }

      if (widget.startAyahIndex > 0 && mounted) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted && _itemScrollController.isAttached) {
            _itemScrollController.jumpTo(
              index: widget.startAyahIndex + (widget.surah != null ? 1 : 0),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _saveLastRead(int ayahIndex) async {
    if (widget.surah == null) return;
    if (!Hive.isBoxOpen('reading_session')) {
      await Hive.openBox('reading_session');
    }
    final box = Hive.box('reading_session');
    await box.put('last_surah_name', widget.surah!.namaLatin);
    await box.put('last_surah_index', widget.surah!.nomor - 1);
    await box.put('last_ayah_index', ayahIndex);
  }

  void _toggleBookmark(int ayahIndex) {
    setState(() {
      if (_bookmarkedAyat.contains(ayahIndex)) {
        _bookmarkedAyat.remove(ayahIndex);
        _showSnack('Penanda dihapus dari Ayat ${ayahIndex + 1}', _textGray);
      } else {
        _bookmarkedAyat.add(ayahIndex);
        _saveLastRead(ayahIndex);
        _showSnack('Ayat ${ayahIndex + 1} ditandai ✓', _gold);
      }
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ));
  }

  void _copyAyat(Ayat ay) {
    final text =
        '${ay.text}\n\n"${ay.translation}"\n\n(${widget.surah?.namaLatin ?? 'Al-Qur\'an'}: ${ay.index})';
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Ayat ${ay.index} disalin ke clipboard', _teal);
  }

  void _shareAyat(Ayat ay) {
    final text =
        '${ay.text}\n\n"${ay.translation}"\n\n— ${widget.surah?.namaLatin ?? 'Al-Qur\'an'} Ayat ${ay.index}\n\n#Quran #HifzhMaster';
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Teks disalin! Buka aplikasi berbagi untuk membagikan.', _gold);
  }

  void _showTafsir(Ayat ay) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: _gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tafsir Ayat ${ay.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.surah?.namaLatin ?? '',
                        style: const TextStyle(color: _textGray, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Arabic Text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  ay.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 22,
                    color: Colors.white,
                    height: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Terjemahan:',
                style: TextStyle(
                  color: _teal,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: ctrl,
                  child: Text(
                    ay.translation,
                    style: const TextStyle(
                      color: _textGray,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAudio(Ayat ay) {
    final surahNum = widget.surah?.nomor ?? (ay.surahId ?? 1);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AyatAudioPlayer(
        surahNumber: surahNum,
        ayahNumber: ay.index,
      ),
    );
  }

  void _scrollToAyah(int listIdx) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: listIdx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _gotoPrev() {
    if (_currentAyahIndex > 0) {
      final isSurahMode = widget.surah != null;
      setState(() => _currentAyahIndex--);
      _scrollToAyah(_currentAyahIndex + (isSurahMode ? 1 : 0));
    }
  }

  void _gotoNext() {
    if (_currentAyahIndex < _ayatList.length - 1) {
      final isSurahMode = widget.surah != null;
      setState(() => _currentAyahIndex++);
      _scrollToAyah(_currentAyahIndex + (isSurahMode ? 1 : 0));
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isSurahMode = widget.surah != null;
    final title =
        isSurahMode ? widget.surah!.namaLatin : 'Juz ${widget.juzNumber}';

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(title),
      body: _loading
          ? _buildLoadingState()
          : _error.isNotEmpty
              ? _buildErrorState()
              : _buildBody(isSurahMode),
      bottomNavigationBar: _loading || _error.isNotEmpty
          ? null
          : _buildBottomActionBar(isSurahMode),
    );
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: _bgColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JuzTestScreen(
                    initialSurah: widget.surah?.nomor,
                    initialJuz: widget.juzNumber,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.quiz_rounded, color: _gold, size: 15),
            label: const Text(
              'UJIAN',
              style: TextStyle(
                color: _gold,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _gold.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _gold, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'Memuat ayat...',
            style: TextStyle(color: _textGray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.red.shade400, size: 52),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: const TextStyle(color: _textGray, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _loading = true; _error = ''; });
                _fetchDetail();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isSurahMode) {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _positionsListener,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 110),
      itemCount: _ayatList.length + (isSurahMode ? 1 : 0),
      itemBuilder: (context, idx) {
        // Header surah
        if (isSurahMode && idx == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: SurahDecorativeHeader(
              surahNameLatin: widget.surah!.namaLatin,
              surahNameArabic: widget.surah!.nama,
              ayatCount: widget.surah!.jumlahAyat,
              location: widget.surah!.tempatTurun,
              surahNumber: widget.surah!.nomor,
            ),
          );
        }

        final realIdx = isSurahMode ? idx - 1 : idx;
        final ay = _ayatList[realIdx];

        // Juz mode: surah separator
        bool showHeader = !isSurahMode && ay.index == 1;

        return Column(
          children: [
            if (showHeader)
              _buildJuzSurahHeader(ay.surahId ?? 1, ay.surahName ?? 'Surah'),
            _buildAyatCard(ay, realIdx),
          ],
        );
      },
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
        surahNumber: surahId,
      ),
    );
  }

  Widget _buildAyatCard(Ayat ay, int realIdx) {
    final isBookmarked = _bookmarkedAyat.contains(realIdx);
    final isCurrent = realIdx == _currentAyahIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? _gold.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.07),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? _gold.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: isCurrent ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Bar: nomor ayat + aksi ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nomor ayat dalam lingkaran bergaya islami
                IslamicAyahSymbol(
                  number: ay.index,
                  size: 44,
                  color: isCurrent ? _gold : _gold.withValues(alpha: 0.7),
                  textColor: isCurrent ? _gold : _gold.withValues(alpha: 0.7),
                ),

                // Action buttons
                Row(
                  children: [
                    _cardActionBtn(
                      icon: Icons.headphones_rounded,
                      tooltip: 'Putar Audio',
                      color: _gold,
                      onTap: () => _showAudio(ay),
                    ),
                    _cardActionBtn(
                      icon: Icons.copy_rounded,
                      tooltip: 'Salin Ayat',
                      color: _teal,
                      onTap: () => _copyAyat(ay),
                    ),
                    _cardActionBtn(
                      icon: isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      tooltip: isBookmarked ? 'Hapus Tandai' : 'Tandai',
                      color: isBookmarked ? _gold : Colors.white38,
                      onTap: () => _toggleBookmark(realIdx),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Teks Arab ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Text(
              ay.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 26,
                height: 2.2,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // ── Terjemahan ──
          if (ay.translation.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _teal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Artinya:',
                        style: TextStyle(
                          color: _teal,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ay.translation,
                    style: const TextStyle(
                      color: _textGray,
                      fontSize: 13.5,
                      height: 1.65,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cardActionBtn({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // ── Bottom Action Bar ───────────────────────────────────────────────────────
  Widget _buildBottomActionBar(bool isSurahMode) {
    final currentAy = _currentAyahIndex < _ayatList.length
        ? _ayatList[_currentAyahIndex]
        : null;
    final hasPrev = _currentAyahIndex > 0;
    final hasNext = _currentAyahIndex < _ayatList.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E33),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              // Navigasi Sebelumnya
              _navBtn(
                icon: Icons.chevron_left_rounded,
                enabled: hasPrev,
                onTap: _gotoPrev,
              ),

              // ── Action buttons ──
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _bottomAction(
                      icon: Icons.menu_book_rounded,
                      label: 'Tafsir',
                      color: _gold,
                      onTap: currentAy != null ? () => _showTafsir(currentAy) : null,
                    ),
                    _bottomAction(
                      icon: Icons.copy_rounded,
                      label: 'Salin',
                      color: _teal,
                      onTap: currentAy != null ? () => _copyAyat(currentAy) : null,
                    ),
                    _bottomAction(
                      icon: Icons.share_rounded,
                      label: 'Bagikan',
                      color: const Color(0xFF818CF8), // Indigo
                      onTap: currentAy != null ? () => _shareAyat(currentAy) : null,
                    ),
                    _bottomAction(
                      icon: Icons.headphones_rounded,
                      label: 'Audio',
                      color: const Color(0xFF34D399), // Emerald
                      onTap: currentAy != null ? () => _showAudio(currentAy) : null,
                    ),
                  ],
                ),
              ),

              // Navigasi Berikutnya
              _navBtn(
                icon: Icons.chevron_right_rounded,
                enabled: hasNext,
                onTap: _gotoNext,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? _gold.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? _gold.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? _gold : Colors.white24,
          size: 24,
        ),
      ),
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
