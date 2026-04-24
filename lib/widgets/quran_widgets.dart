// lib/widgets/quran_widgets.dart
import 'package:flutter/material.dart';

// 8-Point Star / Rub el Hizb or Octagon
class IslamicAyahSymbol extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final Color textColor;
  
  const IslamicAyahSymbol({
    super.key, 
    required this.number, 
    this.size = 36, 
    this.color = const Color(0xFFD4AF37), // Brighter Gold
    this.textColor = const Color(0xFFFFD700) // Bright Gold for text
  });

  String _toArabicNum(int num) {
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    return num.toString().split('').map((e) => arabicDigits[int.parse(e)]).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Slightly more opaque
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.8), width: 1.5),
      ),
      child: Text(
        _toArabicNum(number),
        style: TextStyle(
          fontFamily: 'Amiri', // Use Amiri for authentic look
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
          color: textColor,
          height: 1.2
        ),
      ),
    );
  }
}

// Decorative Header for Surah (Teal Floral Style)
class SurahDecorativeHeader extends StatelessWidget {
  final String surahNameLatin;
  final String surahNameArabic;
  final int ayatCount;
  final String location; // Mekah / Madinah
  final int surahNumber;
  
  const SurahDecorativeHeader({
    super.key,
    required this.surahNameLatin,
    required this.surahNameArabic,
    required this.ayatCount,
    required this.location,
    required this.surahNumber
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF122540);
    const gold = Color(0xFFD4AF37);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal Frame
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
            boxShadow: const [
               BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ]
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
               // Islamic Ornaments at Corners
               Positioned(left: -10, top: -10, child: Icon(Icons.star_outline_rounded, size: 40, color: gold.withOpacity(0.1))),
               Positioned(right: -10, top: -10, child: Icon(Icons.star_outline_rounded, size: 40, color: gold.withOpacity(0.1))),
               Positioned(left: -10, bottom: -10, child: Icon(Icons.star_outline_rounded, size: 40, color: gold.withOpacity(0.1))),
               Positioned(right: -10, bottom: -10, child: Icon(Icons.star_outline_rounded, size: 40, color: gold.withOpacity(0.1))),
               
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   // KIRI: Nama Latin
                   Expanded(
                     flex: 3,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(surahNameLatin, 
                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)
                         ),
                         const SizedBox(height: 2),
                         Text('Surat ke-$surahNumber', 
                           style: const TextStyle(color: Colors.white54, fontSize: 10)
                         ),
                       ],
                     ),
                   ),
                   
                   // TENGAH: Kaligrafi Arab
                   Expanded(
                     flex: 4,
                     child: Text(surahNameArabic, 
                       textAlign: TextAlign.center,
                       style: const TextStyle(fontFamily: 'Amiri', fontSize: 26, color: gold, height: 1.2)
                     ),
                   ),
                   
                   // KANAN: Lokasi & Ayat
                   Expanded(
                     flex: 3,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(location, 
                           style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold)
                         ),
                         const SizedBox(height: 2),
                         Text('$ayatCount Ayat', 
                           style: const TextStyle(color: Colors.white54, fontSize: 10)
                         ),
                       ],
                     ),
                   ),
                 ],
               )
            ],
          ),
        ),
        
        // Bismillah di bawah frame
        if (surahNumber != 1 && surahNumber != 9)
           Container(
             margin: const EdgeInsets.only(bottom: 12),
             child: const Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: Colors.white70),
             ),
           )
      ],
    );
  }
}
