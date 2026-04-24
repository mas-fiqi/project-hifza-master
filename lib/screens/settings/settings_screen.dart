// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Data ──
  List<Map<String, dynamic>> _reminders = [];

  // ── Form pengingat baru (langsung tampil, tanpa tombol +) ──
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final List<bool> _selectedDays = List.filled(7, true); // Sen–Min
  String _selectedLabel = 'Muroja\'ah';

  static const _dayNames  = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
  static const _dayNamesLong = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
  static const _labelOptions = [
    'Muroja\'ah', 'Hafalan Baru', 'Tes Bacaan', 'Tilawah', 'Khataman',
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
    final box = Hive.box('settings');
    final raw = box.get('reminders', defaultValue: []);
    setState(() {
      _reminders = List<Map<String, dynamic>>.from(
          raw.map((e) => Map<String, dynamic>.from(e)));
    });
  }

  Future<void> _saveReminders() async {
    final box = Hive.box('settings');
    await box.put('reminders', _reminders);
  }

  /// Simpan pengingat dari form langsung
  void _addReminderFromForm() {
    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) days.add(i + 1);
    }
    if (days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu hari'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _reminders.add({
        'hour': _selectedTime.hour,
        'minute': _selectedTime.minute,
        'days': days,
        'label': _selectedLabel,
        'active': true,
      });
    });
    _saveReminders();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pengingat berhasil disimpan ✓'),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteReminder(int index) {
    setState(() => _reminders.removeAt(index));
    _saveReminders();
  }

  void _toggleReminder(int index, bool val) {
    setState(() => _reminders[index]['active'] = val);
    _saveReminders();
  }

  String _formatTime(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  String _formatDays(List<dynamic> days) {
    if (days.length == 7) return 'Setiap Hari';
    if (days.isEmpty) return 'Tidak ada hari';
    return days.map((d) => _dayNames[(d as int) - 1]).join(' · ');
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              surface: Color(0xFF122540),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Konstanta Warna ──
  static const _navy     = Color(0xFF0D2137);
  static const _navyCard = Color(0xFF122540);
  static const _gold     = Color(0xFFD4AF37);
  static const _teal     = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO HEADER ──
          SliverToBoxAdapter(child: _buildHeader()),

          // ── FORM BUAT PENGINGAT ──
          SliverToBoxAdapter(child: _buildForm()),

          // ── LIST PENGINGAT TERSIMPAN ──
          SliverToBoxAdapter(child: _buildReminderList()),

          // ── TENTANG ──
          SliverToBoxAdapter(child: _buildAbout()),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, Color(0xFF1A3A5C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Pengaturan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Kaligrafi
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.45)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.03),
            ),
            child: const Text(
              'وَذَكِّرْ فَإِنَّ الذِّكْرَىٰ تَنفَعُ الْمُؤْمِنِينَ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 19,
                  color: _gold,
                  height: 1.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"Dan berilah peringatan, karena sesungguhnya\nperingatan itu bermanfaat bagi orang yang beriman." (QS. Adz-Dzariyat: 55)',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 10.5,
                height: 1.5),
          ),
          const SizedBox(height: 14),

          // Garis ornamental
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Container(height: 1, color: _gold.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('❖',
                      style:
                          TextStyle(color: _gold.withOpacity(0.7), fontSize: 13)),
                ),
                Expanded(child: Container(height: 1, color: _gold.withOpacity(0.3))),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── FORM PENGINGAT ──
  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul form
          Row(
            children: [
              const Icon(Icons.add_alarm_rounded, color: _gold, size: 20),
              const SizedBox(width: 10),
              const Text('Tambah Jadwal Pengingat',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),

          // ── JAM ──
          _FormLabel(label: 'Waktu Pengingat'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _teal.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: _teal, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(_selectedTime.hour, _selectedTime.minute),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_rounded,
                      color: Colors.white.withOpacity(0.3), size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── HARI ──
          _FormLabel(label: 'Hari Pengingat'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = _selectedDays[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedDays[i] = !_selectedDays[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? _teal : Colors.white.withOpacity(0.07),
                    border: Border.all(
                        color: active ? _teal : Colors.white.withOpacity(0.15),
                        width: 1.5),
                  ),
                  child: Center(
                    child: Text(_dayNames[i],
                        style: TextStyle(
                            color: active ? Colors.white : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 18),

          // ── LABEL ──
          _FormLabel(label: 'Label Kegiatan'),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _labelOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = _selectedLabel == _labelOptions[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedLabel = _labelOptions[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? _gold.withOpacity(0.15)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected
                              ? _gold.withOpacity(0.6)
                              : Colors.white.withOpacity(0.15)),
                    ),
                    child: Center(
                      child: Text(_labelOptions[i],
                          style: TextStyle(
                              color: selected ? _gold : Colors.white54,
                              fontSize: 12.5,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── TOMBOL SIMPAN ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addReminderFromForm,
              icon: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF0D2137), size: 20),
              label: const Text('Simpan Pengingat',
                  style: TextStyle(
                      color: Color(0xFF0D2137),
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LIST PENGINGAT ──
  Widget _buildReminderList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_reminders.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.alarm_rounded, color: _gold, size: 18),
                  const SizedBox(width: 8),
                  Text('Jadwal Tersimpan (${_reminders.length})',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
            ..._reminders.asMap().entries.map((entry) {
              final idx = entry.key;
              final r = entry.value;
              final days = r['days'] as List<dynamic>;
              final label = r['label'] as String? ?? 'Pengingat';
              final active = r['active'] as bool? ?? true;

              return Dismissible(
                key: ValueKey('$idx-${r.hashCode}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteReminder(idx),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_rounded,
                      color: Colors.white, size: 22),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: _navyCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: active
                            ? _teal.withOpacity(0.35)
                            : Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      // Ikon
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (active ? _teal : Colors.grey)
                              .withOpacity(0.12),
                          border: Border.all(
                              color: (active ? _teal : Colors.grey)
                                  .withOpacity(0.3)),
                        ),
                        child: Icon(Icons.alarm_rounded,
                            color: active ? _teal : Colors.grey, size: 22),
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTime(r['hour'] as int, r['minute'] as int),
                              style: TextStyle(
                                  color:
                                      active ? Colors.white : Colors.white38,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 3),
                            Text(label,
                                style: TextStyle(
                                    color: active ? _gold : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(_formatDays(days),
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      // Toggle
                      Switch(
                        value: active,
                        onChanged: (val) => _toggleReminder(idx, val),
                        activeColor: _teal,
                        inactiveTrackColor: Colors.white12,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ] else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _navyCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      color: Colors.white.withOpacity(0.25), size: 28),
                  const SizedBox(width: 12),
                  Text('Belum ada jadwal pengingat',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── TENTANG ──
  Widget _buildAbout() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withOpacity(0.3)),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _gold, size: 20),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hifzh Master',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              SizedBox(height: 2),
              Text('Versi 1.0.0 · Aplikasi Hafalan Al-Qur\'an',
                  style: TextStyle(color: Colors.white38, fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── HELPER WIDGET ──
class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5));
  }
}
