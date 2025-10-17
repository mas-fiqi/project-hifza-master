import 'package:flutter/material.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Surah'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 114, // jumlah surah
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.teal)),
            ),
            title: Text('Surah ${index + 1}'),
            subtitle: const Text('Keterangan singkat surah...'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // nanti bisa diarahkan ke detail surah
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Buka Surah ke-${index + 1}')),
              );
            },
          );
        },
      ),
    );
  }
}
