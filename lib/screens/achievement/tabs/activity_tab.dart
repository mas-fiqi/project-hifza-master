// lib/screens/achievement/tabs/activity_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show TextDirection;
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/local_db/hive_manager.dart';
import 'package:intl/intl.dart';

const _navy     = Color(0xFF0D2137);
const _navyCard = Color(0xFF122540);
const _gold     = Color(0xFFD4AF37);
const _teal     = Color(0xFF0D9488);

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveManager.hafalanHistoryBox.listenable(),
      builder: (context, Box box, child) {
        final historyList = HiveManager.getAllHafalanHistory();

        if (historyList.isEmpty) {
          return const _EmptyState();
        }

        // Tampilkan terbaru di atas
        final sorted = [...historyList]..sort((a, b) {
            final da = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
            final db = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
            return db.compareTo(da);
          });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            return _ActivityCard(item: sorted[index], index: index);
          },
        );
      },
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  const _ActivityCard({required this.item, required this.index});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final surahName = widget.item['surahName'] ?? 'Surah';
    final surahArabic = widget.item['surahNameArabic'] as String? ?? '';
    final accuracy = (widget.item['score'] as num?)?.toDouble() ?? 0.0;
    final mistakes = (widget.item['mistakes'] as num?)?.toInt() ?? 0;
    final dateStr = widget.item['date'] as String? ?? '';

    // Konversi errorLogs — Hive menyimpan nested map, perlu di-cast eksplisit
    Map<String, String> errorLogs = {};
    try {
      final raw = widget.item['errorLogs'];
      if (raw != null && raw is Map) {
        raw.forEach((k, v) {
          errorLogs[k.toString()] = v.toString();
        });
      }
    } catch (_) {}

    // Jumlah ayat yang salah = dari errorLogs atau dari field mistakes
    final wrongAyatCount = errorLogs.isNotEmpty ? errorLogs.length : mistakes;

    DateTime? date = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
    final formattedDate = date != null
        ? DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date)
        : 'Tanggal tidak diketahui';
    final formattedTime = date != null ? DateFormat('HH:mm').format(date) : '';

    // Bintang 3 (sesuai sistem app: ≥85%=3, ≥70%=2, ≥50%=1, sisanya 0)
    final stars = accuracy >= 85 ? 3 : accuracy >= 70 ? 2 : accuracy >= 50 ? 1 : 0;

    // Warna aksen berdasarkan skor
    final accent = accuracy >= 85 ? _teal : accuracy >= 50 ? const Color(0xFFD97706) : Colors.red.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // ── HEADER KARTU ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon skor
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.12),
                        border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
                      ),
                      child: Icon(
                        accuracy >= 80
                            ? Icons.gpp_good_rounded
                            : accuracy >= 60
                                ? Icons.warning_amber_rounded
                                : Icons.cancel_rounded,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nama surah + tanggal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (surahArabic.isNotEmpty)
                            Text(surahArabic,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 18,
                                    color: _gold,
                                    height: 1.2)),
                          Text(surahName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: Colors.white38, size: 11),
                              const SizedBox(width: 4),
                              Text(formattedDate,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 11)),
                              if (formattedTime.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.access_time_rounded,
                                    color: Colors.white38, size: 11),
                                const SizedBox(width: 4),
                                Text(formattedTime,
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 11)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Skor besar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${accuracy.toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 26)),
                        Text('skor',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── BINTANG & STATS BAR ──
                Row(
                  children: [
                    // Bintang 3
                    Row(
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: i < stars ? _gold : Colors.white24,
                            size: 22,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Text('$stars/3 bintang',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11)),
                    const Spacer(),

                    // Tombol expand
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Text(_expanded ? 'Sembunyikan' : 'Detail',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 11)),
                            const SizedBox(width: 4),
                            Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.white38,
                                size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Progress bar akurasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Akurasi Bacaan',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 11)),
                        Text('${accuracy.toStringAsFixed(1)}%',
                            style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: accuracy / 100,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(accent),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── DETAIL EXPANDED ──
          if (_expanded) ...[
            Container(height: 1, color: Colors.white.withOpacity(0.07)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row — hanya tampilkan data yang memang ada di Hive
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                          label: 'Total Salah',
                          value: mistakes > 0 ? '$mistakes ×' : '0',
                          color: Colors.red.shade400),
                      _StatChip(
                          label: 'Ayat Bermasalah',
                          value: wrongAyatCount > 0 ? '$wrongAyatCount ayat' : '-',
                          color: const Color(0xFFD97706)),
                      _StatChip(
                          label: 'Akurasi',
                          value: '${accuracy.toStringAsFixed(1)}%',
                          color: accent),
                    ],
                  ),

                  // Error detail per ayat
                  if (errorLogs.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.report_problem_rounded,
                            color: Colors.red, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Detail Ayat Bermasalah (${errorLogs.length} ayat)',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...errorLogs.entries.map((e) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Ayat ${e.key}',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                    e.value.isNotEmpty
                                        ? e.value
                                        : 'Bacaan tidak terdeteksi',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.5),
                                        height: 1.4),
                                    overflow: TextOverflow.visible),
                              ),
                            ],
                          ),
                        )),
                  ] else if (mistakes > 0)
                    // Ada kesalahan dari field mistakes tapi errorLogs kosong
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Terdapat $mistakes kesalahan bacaan.\nDetail per-ayat tidak tercatat untuk sesi ini.',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: _teal, size: 16),
                          const SizedBox(width: 8),
                          Text('Tidak ada kesalahan tercatat 🎉',
                              style: TextStyle(
                                  color: _teal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: _gold.withOpacity(0.2)),
            ),
            child: Icon(Icons.history_toggle_off_rounded,
                size: 52, color: Colors.white.withOpacity(0.2)),
          ),
          const SizedBox(height: 20),
          Text('Riwayat Hafalan Kosong',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Mulai tes bacaan untuk merekam aktivitas',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 13)),
        ],
      ),
    );
  }
}
