// lib/screens/skor/skor_hafalan_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SkorHafalanScreen extends StatefulWidget {
  const SkorHafalanScreen({super.key});

  @override
  State<SkorHafalanScreen> createState() => _SkorHafalanScreenState();
}

class _SkorHafalanScreenState extends State<SkorHafalanScreen> {
  // We use Hive 'history' box.
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        title: const Text('Histori Latihan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Hive.openBox('history'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (Hive.isBoxOpen('history')) {
            final box = Hive.box('history');
            // Convert to list and reverse to show newest first
            final history = box.values.toList().reversed.toList();
            
            if (history.isEmpty) {
              return const Center(child: Text("Belum ada histori latihan"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index] as Map;
                return _HistoriCard(
                  title: item['title'] ?? '-',
                  subtitle: item['subtitle'] ?? '-',
                  points: item['points'] ?? 0,
                  stars: item['stars'] ?? 0,
                );
              },
            );
          } else {
             return const Center(child: Text("Gagal memuat histori"));
          }
        },
      ),
    );
  }
}

class _HistoriCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int points;
  final int stars;

  const _HistoriCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history_edu, color: Colors.teal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points Poin',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
