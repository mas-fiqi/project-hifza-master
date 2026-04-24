// lib/screens/recorder/recorder_widget.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hifzh_master/services/api_config.dart';

class RecorderWidget extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const RecorderWidget({
    Key? key,
    required this.surahNumber,
    required this.ayahNumber,
  }) : super(key: key);

  @override
  State<RecorderWidget> createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget> {
  final Record _recorder = Record();
  bool _isRecording = false;
  String? _filePath;
  double? _uploadProgress;
  Map<String, dynamic>? _lastResponse;

  String get uploadUrl => '${ApiConfig.baseUrl}/voice/evaluate';

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    bool hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin microphone ditolak')),
      );
      return;
    }

    Directory tmpDir = await getTemporaryDirectory();
    String fileName = 'record_${DateTime.now().millisecondsSinceEpoch}.wav';
    String path = '${tmpDir.path}/$fileName';

    await _recorder.start(
      path: path,
      encoder: AudioEncoder.wav,
      bitRate: 128000,
      samplingRate: 16000,
    );

    print("Recording started");

    setState(() {
      _isRecording = true;
      _filePath = path;
      _lastResponse = null;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    String? result = await _recorder.stop();
    print("Recording stopped manually");
    setState(() {
      _isRecording = false;
      _filePath = result ?? _filePath;
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Rekaman selesai, memulai evaluasi...')),
    // );
    
    // Langsung upload begitu selesai
    if (_filePath != null) {
      await _uploadRecording(surah: widget.surahNumber, ayah: widget.ayahNumber);
    }
  }

  Future<void> _uploadRecording({required int surah, required int ayah}) async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada rekaman')));
      return;
    }

    final file = File(_filePath!);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File rekaman tidak ditemukan')));
      return;
    }

    setState(() {
      _uploadProgress = 0.0;
      _lastResponse = null;
    });

    try {
      var uri = Uri.parse(uploadUrl);
      var request = http.MultipartRequest('POST', uri);
      request.fields['surah_number'] = surah.toString();
      request.fields['ayah_number'] = ayah.toString();

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path, filename: file.path.split('/').last),
      );

      final streamed = await request.send();
      // baca response stream
      final bytes = await streamed.stream.toBytes();
      final respString = utf8.decode(bytes);

      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        setState(() {
          _lastResponse = json.decode(respString);
          _uploadProgress = 1.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload berhasil')));
      } else {
        setState(() {
          _uploadProgress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal: ${streamed.statusCode}')));
      }
    } catch (e) {
      setState(() {
        _uploadProgress = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error upload: $e')));
    }
  }

  Widget _buildResponseCard() {
    if (_lastResponse == null) return const SizedBox.shrink();
    final resp = _lastResponse!;
    
    final double accuracy = (resp['score_overall'] ?? 0).toDouble() * 100;
    final int accuracyInt = accuracy.toInt();
    
    int stars = 0;
    if (accuracyInt > 85) {
      stars = 3;
    } else if (accuracyInt >= 60) {
      stars = 2;
    } else if (accuracyInt > 0) {
      stars = 1;
    }

    String starDisplay = '';
    for (int i = 0; i < stars; i++) starDisplay += '⭐';
    if (stars == 0) starDisplay = 'Mohon ulangi bacaan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.teal.shade200, width: 2),
         boxShadow: [
           BoxShadow(
             color: Colors.teal.withOpacity(0.1),
             blurRadius: 10,
             spreadRadius: 2,
             offset: const Offset(0, 4)
           )
         ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Hasil Evaluasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 16),
          Text(
            resp['transcript'] ?? 'Suara kurang jelas', 
            style: const TextStyle(fontSize: 22, height: 1.5, fontFamily: 'Amiri'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                   const Text('Akurasi', style: TextStyle(color: Colors.grey)),
                   Text('$accuracyInt%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                ],
              ),
              Column(
                children: [
                   const Text('Bintang', style: TextStyle(color: Colors.grey)),
                   const SizedBox(height: 4),
                   Text(starDisplay, style: const TextStyle(fontSize: 24)),
                ],
              )
            ],
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink to fit content
        children: [
          Text(
            'Surah ${widget.surahNumber} : Ayat ${widget.ayahNumber}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          if (_uploadProgress == null && _lastResponse == null)
             GestureDetector(
               onTap: () async {
                 if (_isRecording) {
                   await _stopRecording();
                 } else {
                   await _startRecording();
                 }
               },
               child: AnimatedContainer(
                 duration: const Duration(milliseconds: 300),
                 width: _isRecording ? 100 : 80,
                 height: _isRecording ? 100 : 80,
                 decoration: BoxDecoration(
                   color: _isRecording ? Colors.red : Colors.teal,
                   shape: BoxShape.circle,
                   boxShadow: [
                     if (_isRecording) 
                        BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 10)
                   ]
                 ),
                 child: Icon(
                   _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                   color: Colors.white,
                   size: 40,
                 ),
               ),
             ),
             
          if (_uploadProgress == null && _lastResponse == null)
             const SizedBox(height: 16),
             
          if (_uploadProgress == null && _lastResponse == null)
             Text(
               _isRecording ? 'Merekam... Ketuk untuk berhenti' : 'Ketuk untuk merekam hafalan',
               style: TextStyle(color: Colors.grey[600]),
             ),

          if (_uploadProgress != null && _uploadProgress! < 1.0) ...[
             const CircularProgressIndicator(color: Colors.teal),
             const SizedBox(height: 16),
             const Text('Sedang mengevaluasi bacaan...', style: TextStyle(color: Colors.grey)),
          ],

          if (_lastResponse != null) ...[
             _buildResponseCard(),
             const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                 ),
                 onPressed: () => Navigator.pop(context), 
                 child: const Text('Selesai', style: TextStyle(fontSize: 16, color: Colors.white)),
               ),
             )
          ]
        ],
      )
    );
  }
}
