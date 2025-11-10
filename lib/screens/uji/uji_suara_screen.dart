// lib/screens/uji/uji_suara_screen.dart
import 'package:flutter/material.dart';
import 'package:hifzh_master/core/app_routes.dart';

class UjiSuaraScreen extends StatefulWidget {
  const UjiSuaraScreen({super.key});

  @override
  State<UjiSuaraScreen> createState() => _UjiSuaraScreenState();
}

/// definisi tipe option
class _Option {
  final String label;
  final String route;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _Option({
    required this.label,
    required this.route,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

/// daftar opsi utama
const List<_Option> options = [
  _Option(
    label: 'Tilawah',
    route: AppRoutes.latihanMakharij,
    icon: Icons.record_voice_over,
    color: Colors.teal,
    subtitle: 'Tes Makhraj',
  ),
  _Option(
    label: 'Tajwid',
    route: AppRoutes.latihanTajwid,
    icon: Icons.menu_book,
    color: Colors.orange,
    subtitle: 'Test tajwid',
  ),
  _Option(
    label: 'Kalimat',
    route: AppRoutes.hafalanKalimat,
    icon: Icons.format_quote,
    color: Colors.purple,
    subtitle: 'Soal kalimat',
  ),
  _Option(
    label: 'Hafalan',
    route: AppRoutes.ujiSuaraOption,
    icon: Icons.play_circle_fill,
    color: Colors.blue,
    subtitle: 'Stor Hafalan',
  ),
];

class _UjiSuaraScreenState extends State<UjiSuaraScreen> {
  Color _shadowFrom(Color c, [int a = 24]) => Color.fromARGB(a, c.red, c.green, c.blue);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 12.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7EC8FF), Color(0xFF42C3A7), Colors.white],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tes kemampuanmu',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 6),
                        Text('Pilih latihan suara yang ingin dimulai',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            )),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.skorHafalan),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Skor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilihan Latihan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),

                    // Kartu latihan utama
                    LayoutBuilder(builder: (context, constraints) {
                      final tileWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: options.map((opt) {
                          return _OptionTile(
                            width: tileWidth,
                            icon: opt.icon,
                            label: opt.label,
                            subtitle: opt.subtitle,
                            color: opt.color,
                            onTap: () => Navigator.pushNamed(context, opt.route),
                            shadow: _shadowFrom(opt.color, 28),
                          );
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 24),

                    // 🔹 PENCERAHAN LATIHAN
                    const Text('💡 Pencerahan Latihan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    // Scroll horizontal berisi 4 langkah pencerahan
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _GuidanceCard(
                            title: 'Langkah Cepat Menguasai Tajwid',
                            color: Colors.orange,
                            steps: [
                              '1️⃣ Baca 3 huruf dengan hukum tajwid berbeda.',
                              '2️⃣ Dengarkan contoh guru atau audio.',
                              '3️⃣ Ulangi 10 menit per sesi.',
                              '4️⃣ Tes diri lewat fitur Tajwid.',
                            ],
                          ),
                          SizedBox(width: 12),
                          _GuidanceCard(
                            title: 'Latihan Tilawah & Makhraj',
                            color: Colors.teal,
                            steps: [
                              '1️⃣ Latih pengucapan huruf per baris.',
                              '2️⃣ Gunakan fitur Tes Makhraj.',
                              '3️⃣ Fokus pada makhraj huruf yang mirip.',
                              '4️⃣ Latihan 3x sehari untuk kejelasan suara.',
                            ],
                          ),
                          SizedBox(width: 12),
                          _GuidanceCard(
                            title: 'Cara Belajar Kalimat (Sambung Ayat)',
                            color: Colors.purple,
                            steps: [
                              '1️⃣ Hafalkan ayat per kalimat.',
                              '2️⃣ Gunakan fitur sambung kalimat.',
                              '3️⃣ Perhatikan kesambungan arti.',
                              '4️⃣ Ulang 5 kali tiap sesi hafalan.',
                            ],
                          ),
                          SizedBox(width: 12),
                          _GuidanceCard(
                            title: 'Langkah Menyimpan Hafalan',
                            color: Colors.blue,
                            steps: [
                              '1️⃣ Ucapkan hafalan ke fitur Stor Hafalan.',
                              '2️⃣ Lihat hasil warna (Hijau = benar, Merah = salah).',
                              '3️⃣ Perbaiki bacaan hingga semua hijau.',
                              '4️⃣ Ulangi tiap hari agar hafalan kuat.',
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Tag Cepat',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _SmallTag(text: 'Uji Cepat'),
                        _SmallTag(text: 'Mode Tenang'),
                        _SmallTag(text: 'Rekomendasi AI'),
                        _SmallTag(text: 'Sambung Ayat'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile utama (kartu latihan)
class _OptionTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Color shadow;

  const _OptionTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.shadow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color.fromARGB(26, color.red, color.green, color.blue),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Kartu “Pencerahan Latihan”
class _GuidanceCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> steps;

  const _GuidanceCard({
    required this.title,
    required this.color,
    required this.steps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shadow = Color.fromARGB(28, color.red, color.green, color.blue);
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 8),
          ...steps.map((s) => Text(s, style: const TextStyle(fontSize: 12, color: Colors.black87))),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {},
              child: Text("Mulai Latihan", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

/// Tag chip kecil
class _SmallTag extends StatelessWidget {
  final String text;
  const _SmallTag({required this.text, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6)
      ]),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}
