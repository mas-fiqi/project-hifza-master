import 'package:flutter/material.dart';

class MurottalPageScreen extends StatelessWidget {
  const MurottalPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Murottal per Halaman'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 604, // Jumlah halaman Al-Qur'an
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.blueAccent)),
            ),
            title: Text('Halaman ${index + 1}'),
            subtitle: const Text('Klik untuk memutar murottal'),
            trailing: const Icon(Icons.play_arrow, color: Colors.blueAccent),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Memutar Murottal Halaman ${index + 1}')),
              );
            },
          );
        },
      ),
    );
  }
}
