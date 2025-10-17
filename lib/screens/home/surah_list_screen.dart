import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List<dynamic> surahList = [];

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  Future<void> _loadSurahData() async {
    // 🔹 pastikan kamu punya file: assets/data/surah_list.json
    final String response = await rootBundle.loadString('assets/data/surah_list.json');
    final data = await json.decode(response);
    setState(() {
      surahList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Surat Al-Qur'an"),
        backgroundColor: Colors.teal,
      ),
      body: surahList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: surahList.length,
              itemBuilder: (context, index) {
                final surah = surahList[index];
                return ListTile(
                  title: Text(surah['nama']),
                  subtitle: Text("Surah ke-${surah['nomor']} • ${surah['ayat']} ayat"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Nanti bisa diarahkan ke halaman detail surah
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Buka ${surah['nama']}')),
                    );
                  },
                );
              },
            ),
    );
  }
}
