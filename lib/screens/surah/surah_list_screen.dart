// lib/screens/surah/surah_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/surah_model.dart';
import 'surah_detail_screen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List<SurahModel> _surah = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      final raw = await rootBundle.loadString('assets/data/surah_list.json');
      final List data = json.decode(raw) as List;
      setState(() {
        _surah = data.map((e) => SurahModel.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _surah = [];
        _loading = false;
      });
      debugPrint('Gagal load surah_list.json: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Surat Al-Qur'an"), backgroundColor: Colors.teal),
      body: _surah.isEmpty
          ? const Center(child: Text('Tidak ada data surah.'))
          : ListView.separated(
              itemCount: _surah.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = _surah[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${s.nomor}')),
                  title: Text(s.namaLatin),
                  subtitle: Text('${s.nama} • ${s.jumlahAyat} ayat • Juz ${s.juz}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SurahDetailScreen(surah: s))),
                );
              },
            ),
    );
  }
}
