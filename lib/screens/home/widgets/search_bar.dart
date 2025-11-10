// lib/screens/home/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:hifzh_master/screens/search/search_overlay_screen.dart'; // <<< import overlay

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  const SearchBarWidget({super.key, required this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SearchOverlayScreen()),
  );
},

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6)],
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.teal),
            SizedBox(width: 12),
            Expanded(child: Text('Cari Surah atau Ayat...', style: TextStyle(color: Colors.black45))),
          ],
        ),
      ),
    );
  }
}
