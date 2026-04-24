// lib/screens/achievement/certificate_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const _navy     = Color(0xFF0D2137);
const _navyMid  = Color(0xFF1A3A5C);
const _navyCard = Color(0xFF122540);
const _gold     = Color(0xFFD4AF37);
const _teal     = Color(0xFF0D9488);

class CertificateScreen extends StatefulWidget {
  final bool isPreview;
  const CertificateScreen({super.key, this.isPreview = false});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final _nameCtrl        = TextEditingController();
  final _instituteCtrl   = TextEditingController();
  final _formKey         = GlobalKey<FormState>();

  bool _alreadyDownloaded = false;
  String _savedName       = '';
  String _savedInstitute  = '';
  String _savedDate       = '';
  bool   _loading         = true;
  bool   _generating      = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instituteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
    final box = Hive.box('settings');
    final downloaded = box.get('cert_downloaded', defaultValue: false) as bool;
    final name       = box.get('cert_name',        defaultValue: '') as String;
    final institute  = box.get('cert_institute',   defaultValue: '') as String;
    final date       = box.get('cert_date',        defaultValue: '') as String;
    setState(() {
      _alreadyDownloaded = downloaded;
      _savedName         = name;
      _savedInstitute    = institute;
      _savedDate         = date;
      _loading           = false;
    });
  }

  Future<void> _downloadCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    final name      = _nameCtrl.text.trim();
    final institute = _instituteCtrl.text.trim();
    final now       = DateTime.now();
    final dateStr   = DateFormat('dd MMMM yyyy', 'id_ID').format(now);

    setState(() => _generating = true);

    try {
      final pdfBytes = await _buildCertificatePdf(name, institute, dateStr);

      // Simpan ke Hive — tandai sudah didownload (one-time)
      final box = Hive.box('settings');
      await box.put('cert_downloaded', true);
      await box.put('cert_name',       name);
      await box.put('cert_institute',  institute);
      await box.put('cert_date',       dateStr);

      setState(() {
        _alreadyDownloaded = true;
        _savedName         = name;
        _savedInstitute    = institute;
        _savedDate         = dateStr;
        _generating        = false;
      });

      // Buka preview/share dialog PDF bawaan sistem
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Sertifikat_Hafizh_$name.pdf',
      );
    } catch (e) {
      setState(() => _generating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat sertifikat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewDownloadedCertificate() async {
    setState(() => _generating = true);
    try {
      final pdfBytes = await _buildCertificatePdf(
          _savedName, _savedInstitute, _savedDate);
      setState(() => _generating = false);
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Sertifikat_Hafizh_$_savedName.pdf',
      );
    } catch (e) {
      setState(() => _generating = false);
    }
  }

  // ── PDF BUILDER ──
  Future<Uint8List> _buildCertificatePdf(
      String name, String institute, String date) async {
    final doc = pw.Document();

    // Font dasar (helvetica built-in, tanpa perlu asset tambahan)
    final ttf        = await PdfGoogleFonts.cinzelRegular();
    final ttfBold    = await PdfGoogleFonts.cinzelRegular();
    final ttfBody    = await PdfGoogleFonts.crimsonTextRegular();
    final ttfItalic  = await PdfGoogleFonts.crimsonTextItalic();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context ctx) {
          return pw.Stack(
            children: [
              // ── BACKGROUND GRADIENT SIMULASI ──
              pw.Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0D2137),
                ),
              ),

              // ── BORDER LUAR EMAS ──
              pw.Positioned(
                left: 20, right: 20, top: 20, bottom: 20,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFD4AF37),
                      width: 3,
                    ),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                ),
              ),

              // ── BORDER DALAM EMAS ──
              pw.Positioned(
                left: 30, right: 30, top: 30, bottom: 30,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFD4AF37),
                      width: 0.8,
                    ),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                ),
              ),

              // ── KONTEN UTAMA ──
              pw.Positioned.fill(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 60, vertical: 30),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      // Nama Aplikasi
                      pw.Text(
                        'HIFZH MASTER',
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 13,
                          color: const PdfColor.fromInt(0xFF0D9488),
                          letterSpacing: 4,
                        ),
                      ),
                      pw.SizedBox(height: 6),

                      // Garis ornamental
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                              width: 80, height: 0.7,
                              color: const PdfColor.fromInt(0xFFD4AF37)),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                            child: pw.Text('✦',
                                style: pw.TextStyle(
                                    font: ttf,
                                    color: const PdfColor.fromInt(0xFFD4AF37),
                                    fontSize: 10)),
                          ),
                          pw.Container(
                              width: 80, height: 0.7,
                              color: const PdfColor.fromInt(0xFFD4AF37)),
                        ],
                      ),
                      pw.SizedBox(height: 14),

                      // Judul SERTIFIKAT
                      pw.Text(
                        'SERTIFIKAT',
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 38,
                          color: const PdfColor.fromInt(0xFFD4AF37),
                          letterSpacing: 6,
                        ),
                      ),
                      pw.Text(
                        'HAFIZH AL-QUR\'AN',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 18,
                          color: const PdfColor.fromInt(0xFFD4AF37),
                          letterSpacing: 4,
                        ),
                      ),

                      pw.SizedBox(height: 18),

                      // Ayat Arab
                      pw.Text(
                        'إِنَّ الَّذِينَ يَتْلُونَ كِتَابَ اللَّهِ وَأَقَامُوا الصَّلَاةَ',
                        style: pw.TextStyle(
                          font: ttfItalic,
                          fontSize: 12,
                          color: const PdfColor.fromInt(0xFFD4AF37),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '"Sesungguhnya orang-orang yang selalu membaca Kitab Allah..." (QS. Fatir: 29)',
                        style: pw.TextStyle(
                          font: ttfItalic,
                          fontSize: 9,
                          color: const PdfColor.fromInt(0x99FFFFFF),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),

                      pw.SizedBox(height: 24),

                      // Diberikan kepada
                      pw.Text(
                        'Diberikan kepada',
                        style: pw.TextStyle(
                          font: ttfBody,
                          fontSize: 13,
                          color: const PdfColor.fromInt(0x99FFFFFF),
                        ),
                      ),
                      pw.SizedBox(height: 6),

                      // Nama penerima
                      pw.Text(
                        name.toUpperCase(),
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 28,
                          color: PdfColors.white,
                          letterSpacing: 2,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),

                      if (institute.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          institute,
                          style: pw.TextStyle(
                            font: ttfItalic,
                            fontSize: 12,
                            color: const PdfColor.fromInt(0x99FFFFFF),
                          ),
                        ),
                      ],

                      pw.SizedBox(height: 16),

                      // Garis
                      pw.Container(
                          width: 260, height: 1,
                          color: const PdfColor.fromInt(0xFFD4AF37)),
                      pw.SizedBox(height: 6),

                      // Keterangan prestasi
                      pw.Text(
                        'Telah berhasil menyelesaikan hafalan 30 Juz Al-Qur\'an',
                        style: pw.TextStyle(
                          font: ttfBody,
                          fontSize: 13,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'melalui Aplikasi Hifzh Master dengan dedikasi dan ketekunan yang luar biasa.',
                        style: pw.TextStyle(
                          font: ttfBody,
                          fontSize: 11,
                          color: const PdfColor.fromInt(0xBBFFFFFF),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),

                      pw.SizedBox(height: 20),

                      // Footer: tanggal + tanda tangan area
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          // Tanggal
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Tanggal Diterbitkan',
                                  style: pw.TextStyle(
                                      font: ttfBody,
                                      fontSize: 9,
                                      color: const PdfColor.fromInt(0x99FFFFFF))),
                              pw.Text(date,
                                  style: pw.TextStyle(
                                      font: ttfBold,
                                      fontSize: 12,
                                      color: const PdfColor.fromInt(0xFFD4AF37))),
                            ],
                          ),

                          // Nomor sertifikat
                          pw.Column(
                            children: [
                              pw.Text(
                                'No. CERT/${DateFormat('yyyyMMdd').format(DateTime.now())}-${name.hashCode.abs().toString().substring(0, 4)}',
                                style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 9,
                                    color: const PdfColor.fromInt(0x55FFFFFF)),
                              ),
                            ],
                          ),

                          // Tanda tangan
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Penyelenggara',
                                  style: pw.TextStyle(
                                      font: ttfBody,
                                      fontSize: 9,
                                      color: const PdfColor.fromInt(0x99FFFFFF))),
                              pw.SizedBox(height: 16),
                              pw.Container(
                                  width: 100, height: 0.5,
                                  color: const PdfColor.fromInt(0xFFD4AF37)),
                              pw.Text('Hifzh Master App',
                                  style: pw.TextStyle(
                                      font: ttfBold,
                                      fontSize: 10,
                                      color: const PdfColor.fromInt(0xFFD4AF37))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // ── BUILD UI ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _gold))
                : _alreadyDownloaded
                    ? _buildAlreadyDownloaded()
                    : _buildForm(),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _navyMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(widget.isPreview ? 'Preview Sertifikat' : 'Sertifikat Hafizh',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withOpacity(0.4)),
                    ),
                    child: const Text('30 Juz ✓',
                        style: TextStyle(
                            color: _gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Kaligrafi
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.35)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.03),
            ),
            child: Column(
              children: [
                const Text(
                  'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 19,
                      color: _gold,
                      height: 1.6),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Sebaik-baik kalian adalah yang belajar Al-Qur\'an dan mengajarkannya." (HR. Bukhari)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withOpacity(0.45),
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Garis ornamental
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        height: 1,
                        color: _gold.withOpacity(0.25))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('❖',
                      style: TextStyle(
                          color: _gold.withOpacity(0.6), fontSize: 13)),
                ),
                Expanded(
                    child: Container(
                        height: 1,
                        color: _gold.withOpacity(0.25))),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // ── FORM ──
  Widget _buildForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning one-time
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: _gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ Sertifikat hanya bisa di-download SATU KALI.\nPastikan nama dan data yang diisi sudah benar.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.5,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Preview sertifikat mini
            _buildCertPreview(),
            const SizedBox(height: 24),

            if (widget.isPreview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _navyCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: _gold, size: 28),
                    const SizedBox(height: 12),
                    const Text('Formulir Terkunci', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      'Selesaikan hafalan 30 Juz untuk mengisi data diri & men-download sertifikat resmi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),

            _fieldLabel('Nama Lengkap *'),
            const SizedBox(height: 8),
            _buildField(
              controller: _nameCtrl,
              enabled: !widget.isPreview,
              hint: widget.isPreview ? 'NAMA ANDA (Preview)' : 'Masukkan nama lengkap Anda',
              icon: Icons.person_rounded,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),

            _fieldLabel('Asal Institusi / Pesantren (Opsional)'),
            const SizedBox(height: 8),
            _buildField(
              controller: _instituteCtrl,
              enabled: !widget.isPreview,
              hint: widget.isPreview ? 'Asal Institusi (Preview)' : 'Misal: PP. Al-Hidayah, Surabaya',
              icon: Icons.school_rounded,
            ),
            const SizedBox(height: 32),

            // Tombol download
            SizedBox(
              width: double.infinity,
              child: _generating
                  ? Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white)),
                            SizedBox(width: 12),
                            Text('Membuat Sertifikat...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: widget.isPreview ? null : _downloadCertificate,
                      icon: Icon(
                          widget.isPreview ? Icons.lock_rounded : Icons.download_rounded,
                          color: widget.isPreview ? Colors.white38 : const Color(0xFF0D2137), 
                          size: 22),
                      label: Text(
                          widget.isPreview ? 'Belum Bisa Di-download' : 'Download Sertifikat PDF',
                          style: TextStyle(
                              color: widget.isPreview ? Colors.white38 : const Color(0xFF0D2137),
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isPreview ? Colors.white.withOpacity(0.05) : _gold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SUDAH DOWNLOAD ──
  Widget _buildAlreadyDownloaded() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: _gold, size: 56),
            ),
            const SizedBox(height: 20),
            const Text('Sertifikat Telah Diterbitkan',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 8),

            // Info sertifikat tersimpan
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _navyCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.person_rounded, 'Nama', _savedName),
                  const SizedBox(height: 8),
                  if (_savedInstitute.isNotEmpty)
                    _infoRow(Icons.school_rounded, 'Institusi', _savedInstitute),
                  if (_savedInstitute.isNotEmpty) const SizedBox(height: 8),
                  _infoRow(Icons.calendar_today_rounded, 'Tanggal', _savedDate),
                ],
              ),
            ),

            Text(
              'Sertifikat hanya bisa di-download satu kali.\nTekan tombol di bawah untuk membuka atau menyimpan kembali.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12.5,
                  height: 1.5),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _generating ? null : _viewDownloadedCertificate,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF0D2137)))
                  : const Icon(Icons.picture_as_pdf_rounded,
                      color: Color(0xFF0D2137), size: 20),
              label: Text(
                _generating ? 'Membuka...' : 'Buka / Cetak Sertifikat',
                style: const TextStyle(
                    color: Color(0xFF0D2137),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PREVIEW SERTIFIKAT MINI ──
  Widget _buildCertPreview() {
    return Container(
      width: double.infinity,
      height: 235, // Ditingkatkan untuk menghindari overflow
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.5), width: 1.5),
      ),
      child: Stack(
        children: [
          // Dekoratif ikon besar
          Positioned(
            right: -10, top: -10,
            child: Icon(Icons.workspace_premium_rounded,
                size: 130,
                color: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(18), // Sedikit dikurangi dari 20
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HIFZH MASTER',
                    style: TextStyle(
                        color: _teal,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3)),
                const SizedBox(height: 4),
                const Text('SERTIFIKAT',
                    style: TextStyle(
                        color: _gold,
                        fontSize: 24, // Sedikit dikurangi dari 26
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4)),
                const Text('HAFIZH AL-QUR\'AN',
                    style: TextStyle(
                        color: _gold,
                        fontSize: 11, // Sedikit dikurangi dari 12
                        letterSpacing: 3)),
                const SizedBox(height: 10),
                Text('Diberikan kepada',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11)),
                const SizedBox(height: 3),
                Text(
                  _nameCtrl.text.isEmpty
                      ? (widget.isPreview ? 'NAMA ANDA (PREVIEW)' : '[NAMA ANDA]')
                      : _nameCtrl.text.toUpperCase(),
                  style: TextStyle(
                      color: widget.isPreview ? Colors.white38 : Colors.white,
                      fontSize: 17, // Sedikit dikurangi dari 18
                      fontWeight: FontWeight.bold),
                ),
                if (widget.isPreview) ...[
                  const Spacer(),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: _gold.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('HANYA PREVIEW', 
                        style: TextStyle(color: _gold.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: _gold.withOpacity(0.4)),
                      ),
                      child: const Text('30 Juz ✓',
                          style: TextStyle(
                              color: _gold,
                              fontSize: 9, // Sedikit dikurangi dari 10
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 14),
      cursorColor: _gold,
      onChanged: (_) => setState(() {}), // update preview
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: enabled ? _gold.withOpacity(0.7) : Colors.white24, size: 20),
        filled: true,
        fillColor: enabled ? _navyCard : Colors.white.withOpacity(0.02),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5));
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _gold, size: 16),
        const SizedBox(width: 10),
        Text('$label: ',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 12)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
