// lib/screens/search/search_overlay_screen.dart
import 'package:flutter/material.dart';

import '../../models/quran_model.dart';
import '../../services/quran_service.dart';
import '../../data/local_db/hive_manager.dart';
import '../quran/quran_reader_screen.dart';

class SearchOverlayScreen extends StatefulWidget {
  const SearchOverlayScreen({super.key});

  @override
  State<SearchOverlayScreen> createState() => _SearchOverlayScreenState();
}

class _SearchOverlayScreenState extends State<SearchOverlayScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Surah> _allSurah = [];
  List<Surah> _results = [];
  List<String> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _history = HiveManager.loadSearchHistory();
    _fetchSurahList();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchSurahList() async {
    try {
      final list = await QuranService.getSurahList();
      setState(() {
        _allSurah = list;
        _results = List.from(_allSurah);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Gagal fetch surah list: $e');
      setState(() {
        _allSurah = [];
        _results = [];
        _isLoading = false;
      });
    }
  }

  void _onQueryChanged() {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _results = List.from(_allSurah));
    } else {
      setState(() {
        final qNormalized = q.replaceAll('jus', 'juz').replaceAll(' ', '');
        
        // Normalize transliteration differences (yasin vs ya sin, baqarah vs baqara)
        String normalizeString(String text) {
           return text.toLowerCase()
              .replaceAll(RegExp('[\\s\\-\\\'\\"’‘]'), '') // remove spaces, hyphens, quotes
              .replaceAll('ee', 'i')
              .replaceAll('oo', 'u')
              .replaceAll(RegExp(r'([aiueo])\1+'), r'$1') // remove double vowels (aa->a)
              .replaceAll(RegExp(r'ah$'), 'a'); // baqarah -> baqara
        }
        
        final cleanQ = normalizeString(q);
        
        _results = _allSurah.where((s) {
          final cleanNama = normalizeString(s.nama);
          final cleanLatin = normalizeString(s.namaLatin);
          
          final matchNama = cleanNama.contains(cleanQ);
          final matchLatin = cleanLatin.contains(cleanQ);
          final matchNomor = s.nomor.toString() == cleanQ;
          final matchJuz = s.juz.toString() == q || 'juz${s.juz}' == qNormalized;
          return matchNama || matchLatin || matchNomor || matchJuz;
        }).toList();
      });
    }
  }

  void _addToHistory(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _history.remove(t);
    _history.insert(0, t);
    if (_history.length > 20) _history.removeLast();
    HiveManager.saveSearchHistory(_history);
    setState(() {});
  }

  void _onTapResult(Surah surah) {
    _addToHistory('${surah.nomor} ${surah.namaLatin}');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuranReaderScreen(surah: surah),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF0F9D58);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0,
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: _buildSearchBox(primary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Riwayat Pencarian
              if (_history.isNotEmpty) ...[
                const Text(
                  'Riwayat Pencarian',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _history.map((h) {
                    return ActionChip(
                      label: Text(h),
                      onPressed: () {
                        _controller.text = h;
                        _onQueryChanged();
                        _focusNode.requestFocus();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              const Text(
                'Hasil / Daftar Surah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Hasil pencarian
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              _controller.text.isEmpty
                                  ? 'Tidak ada data surah.'
                                  : 'Tidak ada hasil untuk "${_controller.text}"',
                            ),
                          )
                        : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primary.withAlpha(100),
                              child: Text(
                                '${s.nomor}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                            title: Text(
                              s.namaLatin,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                                '${s.nama} • ${s.jumlahAyat} ayat • Juz ${s.juz}'),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                            onTap: () => _onTapResult(s),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kotak input pencarian
  Widget _buildSearchBox(Color primary) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: false, // overlay muncul tanpa keyboard
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari Surah atau Ayat...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onTap: () {
                  // ketika user mengetuk field -> keyboard akan muncul
                  _focusNode.requestFocus();
                },
                onSubmitted: (v) {
                  _addToHistory(v);
                },
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.grey,
                onPressed: () {
                  _controller.clear();
                  _onQueryChanged();
                  _focusNode.requestFocus();
                },
              ),
          ],
        ),
      ),
    );
  }
}
