import 'package:flutter/material.dart';

class UjiTulisanScreen extends StatelessWidget {
  const UjiTulisanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================================================
      // AppBar: Warna emas lembut agar terlihat elegan
      // =========================================================
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.amberAccent,
        title: const Text(
          'Uji Hafalan Tulisan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      // =========================================================
      // Body dengan Scroll agar responsif di semua layar
      // =========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------
            // HEADER: Tampilan dekoratif atas
            // -----------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.amber.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade200.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(Icons.menu_book_rounded, color: Colors.white, size: 60),
                  SizedBox(height: 10),
                  Text(
                    'Lanjutkan ayat berikut :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------------------------------
            // SOAL AYAT DALAM TULISAN ARAB
            // -----------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
              ),
              child: const Text(
                'ٱلْـحَمْدُ لِلّٰهِ رَبِّ ٱلْعَٰلَمِينَ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl, // arah tulisan kanan ke kiri
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Amiri', // font arab elegan
                  color: Colors.brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -----------------------------------------------------
            // Instruksi menulis jawaban
            // -----------------------------------------------------
            const Text(
              'Tuliskan lanjutan ayatnya di bawah ini:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // -----------------------------------------------------
            // TextField tempat pengguna menulis ayat
            // -----------------------------------------------------
            TextField(
              maxLines: 5,
              textDirection: TextDirection.rtl, // arah tulisan kanan ke kiri
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Amiri',
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'اُكْتُبْ الْآيَةَ هُنَا...',
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.amber.shade400, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.amber.shade700, width: 2.0),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------------------------------
            // Tombol Kirim Jawaban
            // -----------------------------------------------------
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Jawaban telah dikirim! Semoga hafalanmu benar 😊',
                        textDirection: TextDirection.rtl,
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'إِرْسَالُ الْإِجَابَةِ', // "Kirim Jawaban" versi Arab
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Amiri',
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
