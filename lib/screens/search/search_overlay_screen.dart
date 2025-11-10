// lib/screens/search/search_overlay_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../models/surah_model.dart';
import '../../data/local_db/hive_manager.dart'; // ✅ ganti dari SimpleHive ke HiveManager
import '../surah/surah_detail_screen.dart';

class SearchOverlayScreen extends StatefulWidget {
  const SearchOverlayScreen({super.key});

  @override
  State<SearchOverlayScreen> createState() => _SearchOverlayScreenState();
}

class _SearchOverlayScreenState extends State<SearchOverlayScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SurahModel> _allSurah = [];
  List<SurahModel> _results = [];
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    // Load riwayat dari HiveManager (sudah diinisialisasi di main.dart)
    _history = HiveManager.loadSearchHistory();
    _loadSurahJson();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Load daftar surah dari file JSON
  Future<void> _loadSurahJson() async {
    try {
      final raw = await rootBundle.loadString('assets/data/surah_list.json');
      final List<dynamic> data = json.decode(raw) as List<dynamic>;
      _allSurah = data
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _results = List.from(_allSurah);
      });
    } catch (e) {
      debugPrint('❌ Gagal load surah_list.json: $e');
      setState(() {
        _allSurah = [];
        _results = [];
      });
    }
  }

  /// Listener pencarian
  void _onQueryChanged() {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _results = List.from(_allSurah));
    } else {
      setState(() {
        _results = _allSurah.where((s) {
          final matchNama = s.nama.toLowerCase().contains(q);
          final matchLatin = s.namaLatin.toLowerCase().contains(q);
          final matchNomor = s.nomor.toString() == q;
          return matchNama || matchLatin || matchNomor;
        }).toList();
      });
    }
  }

  /// Tambahkan kata ke riwayat pencarian
  void _addToHistory(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _history.remove(t);
    _history.insert(0, t);
    if (_history.length > 20) _history.removeLast();
    HiveManager.saveSearchHistory(_history);
    setState(() {});
  }

  /// Saat user men-tap hasil pencarian
  void _onTapResult(SurahModel surah) {
    _addToHistory('${surah.nomor} ${surah.namaLatin}');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SurahDetailScreen(surah: surah),
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
                child: _results.isEmpty
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
