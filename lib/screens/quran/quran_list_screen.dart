// lib/screens/quran/quran_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '/models/quran_model.dart';
import 'quran_reader_screen.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  List<Surah> _surah = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/data/quran.json');
      final list = json.decode(raw) as List<dynamic>;
      _surah = list.map((e) => Surah.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Gagal load data: $e';
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error.isNotEmpty) return Scaffold(body: Center(child: Text(_error)));

    return Scaffold(
      appBar: AppBar(title: const Text('Kitab Suci — Daftar Surah')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _surah.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = _surah[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${s.nomor}')),
            title: Text(s.namaLatin),
            subtitle: Text('${s.nama} • ${s.jumlahAyat} ayat • Juz ${s.juz}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: s)));
            },
          );
        },
      ),
    );
  }
}
