import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:hifzh_master/services/quran_data_service.dart';
import 'package:hifzh_master/data/local_db/hive_manager.dart';
import 'package:hifzh_master/data/surah_data.dart';
import 'package:hifzh_master/data/juz_data.dart';
import 'package:hifzh_master/widgets/quran_widgets.dart';

enum RecordStatus { idle, listening, processing, paused }

class JuzTestScreen extends StatefulWidget {
  final int? initialSurah;
  final int? initialJuz;

  const JuzTestScreen({
    super.key,
    this.initialSurah,
    this.initialJuz,
  });

  @override
  State<JuzTestScreen> createState() => _JuzTestScreenState();
}

class _JuzTestScreenState extends State<JuzTestScreen> with SingleTickerProviderStateMixin {
  // ===== COLORS (Islamic Navy & Gold) =====
  static const _navy     = Color(0xFF0D2137);
  static const _navyCard = Color(0xFF122540);
  static const _gold     = Color(0xFFD4AF37);
  static const _teal     = Color(0xFF0D9488);

  // ===== STATE DATA =====
  List<Map<String, dynamic>> _sessionAyats = []; // Gabungan ayat untuk sesi ini
  
  Map<int, String> _ayatResult = {}; // Key: Unique Index dalam sessionAyats
  Map<int, String> _ayatErrors = {}; 
  int _mistakes = 0;
  int _currentStep = 1; // 1-indexed based on _sessionAyats
  bool _isFinished = false;

  // Flashback system: 1x retry per sesi
  bool _flashbackUsed = false;
  bool _isRetryingAyat = false; // true saat user sedang mengulang ayat yang salah

  // Evaluation tracking (prefix tracking removed for strict isolation)
  // ===== STATE REKAMAN =====
  RecordStatus _recordStatus = RecordStatus.idle;
  late stt.SpeechToText _speech;
  String _currentLocaleId = 'ar-SA';
  bool _isManualRecording = false;
  String _sessionBuffer = "";
  String _lastRecognizedWords = "";
  String _liveSpeech = "";
  Timer? _silenceTimer;
  int _secondsSinceLastWord = 0;
  bool _isTransitioning = false;
  String _processedRawPrefix = "";
  bool _isCalculatingScore = false;
  
  // Pre-compiled RegEx for performance (Gercep)
  // Menjaga huruf dasar Arab, Hamzah, dan Alif Wasla
  final _arabKeepRegex = RegExp(r'[^\u0621-\u064A\u0671]'); 
  final _arabAlifRegex = RegExp(r'[أإآٱ]');
  final _latinNormRegex = RegExp(r'[^a-z0-9]');

  final ItemScrollController _itemScrollController = ItemScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _speech = stt.SpeechToText();
    _loadData();
    _initSpeech();
  }

  @override
  void dispose() {
    _isManualRecording = false;
    _speech.stop();
    _silenceTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ===== LOAD DATA =====
  void _loadData() {
    setState(() {
      if (widget.initialJuz != null) {
        final j = widget.initialJuz!;
        final map = JuzData.juzMapping[j]!;
        _sessionAyats = QuranDataService().getJuzAyats(
          map['startSurah'], map['startAyat'], 
          map['endSurah'], map['endAyat']
        );
      } else {
        final s = widget.initialSurah ?? 1;
        _sessionAyats = QuranDataService().getAyats(s).map((e) {
          var m = Map<String, dynamic>.from(e);
          m['isFirstAyatOfSurah'] = (m['ayat'] == 1);
          return m;
        }).toList();
      }

      _ayatResult = {};
      _ayatErrors = {};
      _mistakes = 0;
      _currentStep = 1;
      _isFinished = false;
      _flashbackUsed = false;
      _isRetryingAyat = false;
      _resetEvalPointers();
    });
  }

  void _resetEvalPointers() {
    // No longer needed due to strict isolation
  }

  // ===== SPEECH & LOGIC =====
  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (val) {
          print("[DEBUG-STT] Error: ${val.errorMsg} - Permanent: ${val.permanent}");
          if (_isManualRecording && mounted && !_isFinished) {
             _sessionBuffer = ("$_sessionBuffer $_lastRecognizedWords").trim();
             _lastRecognizedWords = "";
             Future.delayed(const Duration(milliseconds: 800), () {
                if (_isManualRecording && mounted) _startListening(isRestart: true);
             });
          }
        },
        onStatus: (val) {
          print("[DEBUG-STT] Status: $val");
          if (val == 'done' && mounted && _isManualRecording && !_isFinished) {
             _sessionBuffer = ("$_sessionBuffer $_lastRecognizedWords").trim();
             _lastRecognizedWords = "";
             Future.delayed(const Duration(milliseconds: 800), () {
                if (_isManualRecording && mounted) _startListening(isRestart: true);
             });
          }
        },
      );
      if (available && mounted) {
        // Cek apakah ar-SA didukung
        var locales = await _speech.locales();
        bool hasAr = locales.any((l) => l.localeId.contains('ar'));
        print("[DEBUG-STT] Available Locales: ${locales.length}. Has Arabic: $hasAr");
        
        setState(() => _currentLocaleId = hasAr 
          ? locales.firstWhere((l) => l.localeId.contains('ar')).localeId 
          : 'ar-SA');
      }
    } catch (_) {}
  }

  void _startListening({bool isRestart = false}) {
    if (_isFinished) return;
    setState(() {
      _recordStatus = RecordStatus.listening;
      _isManualRecording = true;
      _isTransitioning = false; // Buka kunci saat sesi baru dimulai
      if (!isRestart) {
        print("[DEBUG-STT] Resetting Buffers & Releasing Lock");
        // Strict isolation: always clear buffer when not a continuous restart
        _sessionBuffer = "";
        _lastRecognizedWords = "";
        _liveSpeech = "";
        _startSilenceTimer();
      }
    });
    _speech.listen(
      onResult: (val) {
        if (_recordStatus != RecordStatus.listening || _isTransitioning) return;
        if (val.recognizedWords.isNotEmpty) {
          _lastRecognizedWords = val.recognizedWords;
          _secondsSinceLastWord = 0;
          
          // Gercep: Update UI immediately
          if (_liveSpeech != val.recognizedWords) {
            setState(() => _liveSpeech = val.recognizedWords);
          }
          
          // Then evaluate match
          _evaluateBuffer(forceFail: false);
        }
      },
      localeId: _currentLocaleId,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: false,
    );
  }

  void _pauseListening() {
    _sessionBuffer = ("$_sessionBuffer $_lastRecognizedWords").trim();
    _lastRecognizedWords = "";
    
    _isManualRecording = false;
    _silenceTimer?.cancel();
    _speech.stop();
    setState(() => _recordStatus = RecordStatus.paused);
  }

  void _stopListening() {
    _sessionBuffer = ("$_sessionBuffer $_lastRecognizedWords").trim();
    _lastRecognizedWords = "";

    _isManualRecording = false;
    _silenceTimer?.cancel();
    _speech.stop();
    setState(() => _recordStatus = RecordStatus.idle);
    if (!_isFinished) {
      if (_currentStep <= _sessionAyats.length) _evaluateBuffer(forceFail: true);
      _finishTest();
    }
  }

  void _toggleMic() => _recordStatus == RecordStatus.listening ? _pauseListening() : _startListening(isRestart: _recordStatus == RecordStatus.paused);

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _secondsSinceLastWord = 0;
    _silenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isManualRecording || _isFinished) { timer.cancel(); return; }
      _secondsSinceLastWord++;
      if (_secondsSinceLastWord >= 3) { // REDUCED TO 3 SECONDS
        _secondsSinceLastWord = 0; // Reset agar tidak otomatis gagalkan ayat berikutnya
        _evaluateBuffer(forceFail: true);
      }
    });
  }

  // ===== EVALUATION ENGINE =====
  void _evaluateBuffer({bool forceFail = false}) {
    if (_currentStep > _sessionAyats.length || _isTransitioning) return;

    int idx = _currentStep - 1;
    var target = _sessionAyats[idx];
    
    final targetArab = _normalizeArab(target["arab"]?.toString() ?? "");
    
    String speech = ("$_sessionBuffer $_lastRecognizedWords").trim();
    if (speech.isEmpty && !forceFail) return;
    
    // VISUAL UPDATE FOR LIVE BOX
    String visualSpeech = speech;
    if (_liveSpeech != visualSpeech) setState(() => _liveSpeech = visualSpeech);
    
    final normArab = _normalizeArab(speech);

    print("[DEBUG-EVAL] --- EVALUASI AYAT KE-${idx + 1} ---");
    print("[DEBUG-EVAL] Buffer State: '$_sessionBuffer' + '$_lastRecognizedWords'");
    print("[DEBUG-EVAL] Mendengar suara: '$speech'");
    print("[DEBUG-EVAL] Normalisasi: '$normArab'");

    bool isMatch = false;
    double simArab = 0.0;
    
    // Quick word-by-word match check for early feedback (Gercep)
    if (forceFail || normArab.length >= targetArab.length * 0.6) {
      simArab = _calculateSimilarity(_stripAlif(normArab), _stripAlif(targetArab));
      isMatch = simArab >= 0.88;
    }

    // AUTO-FAIL IF SPEECH EXCEEDS TARGET LENGTH (Kompleks salah -> Lanjut)
    int targetWordCount = target["arab"]?.toString().trim().split(RegExp(r'\s+')).length ?? 1;
    int speechWordCount = speech.trim().split(RegExp(r'\s+')).length;
    if (!isMatch && speechWordCount >= targetWordCount + 2) {
       forceFail = true;
    }

    print("[DEBUG-EVAL] Target Ayat ke-${idx + 1}: '$targetArab'");
    print("[DEBUG-EVAL] Score Kemiripan: ${(simArab * 100).toStringAsFixed(1)}% | isMatch: $isMatch");

    if (isMatch) {
      print("[DEBUG-EVAL] => STATUS: BERHASIL! Lanjut ayat berikutnya.");
      _silenceTimer?.cancel(); // Stop timer immediately
      setState(() {
        _isTransitioning = true; 
        _ayatResult[idx] = target["arab"];
        _ayatErrors.remove(idx);
        _isRetryingAyat = false;
        
        // Wipe everything immediately
        _sessionBuffer = "";
        _lastRecognizedWords = "";
        _liveSpeech = "";
        
        _currentStep++;
      });
      _advanceAfterEval();
    } else if (forceFail) {
      if (visualSpeech.isEmpty) return; // Murni hening ambil napas. Jangan skip!

      if (_isRetryingAyat) {
        // Sedang retry tapi tetap salah → permanen salah, advance
        print("[DEBUG-EVAL] => STATUS: RETRY GAGAL di ayat ke-${idx + 1}. Tetap salah, advance.");
        setState(() {
          _ayatErrors[idx] = visualSpeech;
          _isRetryingAyat = false;
          _currentStep++;
        });
        _advanceAfterEval();
      } else if (!_flashbackUsed) {
        // Flashback belum dipakai → beri kesempatan ulangi 1x
        print("[DEBUG-EVAL] => STATUS: SALAH di ayat ke-${idx + 1}. FLASHBACK tersedia! Pause & tunggu retry.");
        _flashbackUsed = true;
        setState(() {
          _ayatErrors[idx] = visualSpeech;
          _mistakes++;
          _isRetryingAyat = true;
          _secondsSinceLastWord = 0;
          
          // Clear immediately so retry starts fresh
          _sessionBuffer = "";
          _lastRecognizedWords = "";
          _liveSpeech = "";
        });
        _pauseListening(); // Mic mati, tunggu user pencet ulang
      } else {
        // Flashback sudah habis → langsung permanen salah, otomatis lanjut
        print("[DEBUG-EVAL] => STATUS: GAGAL PERMANEN di ayat ke-${idx + 1}. Flashback habis, auto-advance.");
        setState(() {
          _ayatErrors[idx] = visualSpeech;
          _mistakes++;
          _secondsSinceLastWord = 0;
          _currentStep++;
          
          // Immediate buffer clear to prevent ghost text
          _sessionBuffer = "";
          _lastRecognizedWords = "";
          _liveSpeech = "";
        });
        _advanceAfterEval();
      }
    } else {
      if (visualSpeech.isNotEmpty) setState(() => _ayatErrors[idx] = visualSpeech);
    }
  }



  void _finishTest() {
    _isFinished = true;
    _recordStatus = RecordStatus.idle;
    // Calculation Accuracy
    double acc = (_ayatResult.length / _sessionAyats.length) * 100;
    acc -= (_mistakes * 2);
    if (acc < 0) acc = 0;

    int surahId = _sessionAyats.isNotEmpty ? (_sessionAyats[0]['surah_id'] ?? 1) : 1;
    String name = widget.initialJuz != null ? "Juz ${widget.initialJuz}" : (widget.initialSurah != null ? SurahData.allSurahNames[widget.initialSurah!-1] : SurahData.allSurahNames[surahId-1]);
    String nameArab = widget.initialJuz != null ? "الجزء ${widget.initialJuz}" : (widget.initialSurah != null ? SurahData.allSurahNamesArabic[widget.initialSurah!-1] : SurahData.allSurahNamesArabic[surahId-1]);

    if (_sessionAyats.isEmpty) return; // Failsafe if empty

    Map<String, String> mappedErrors = {};
    _ayatErrors.forEach((idx, speechResult) {
       final realAyatNum = _sessionAyats[idx]['ayat'] ?? (idx + 1);
       mappedErrors[realAyatNum.toString()] = speechResult;
    });

    HiveManager.addHafalanHistory({
      'surahId': surahId,
      'surahName': name,
      'surahNameArabic': nameArab,
      'ayahCount': _sessionAyats.length,
      'score': acc,
      'mistakes': _mistakes,
      'errorLogs': mappedErrors,
      'date': DateTime.now().toIso8601String(),
    });

    _showEvaluationModal(acc);
  }

  // ===== NORMALIZERS & MATH (Optimized) =====
  String _normalizeArab(String t) {
    if (t.isEmpty) return "";
    return t
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Buang harakat & Alif Khanjariyah
      .replaceAll(_arabAlifRegex, 'ا')                 // Samakan Alif (termasuk Wasla)
      .replaceAll('ى', 'ي')                            // Samakan Alif Maqsura
      .replaceAll('ة', 'ه')                            // Samakan Ta Marbuthah
      .replaceAll(_arabKeepRegex, '')                  // Buang karakter non-huruf Arab sisa
      .replaceAll(' ', '');                            // Buang spasi
  }

  String _stripAlif(String t) => t.replaceAll('ا', '');
  String _normalizeLatin(String t) => t.toLowerCase().replaceAll(_latinNormRegex, '');
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0; if (s1.isEmpty || s2.isEmpty) return 0.0;
    List<int> p = List.generate(s2.length+1, (i)=>i);
    for(int i=0; i<s1.length; i++){
      List<int> c = [i+1];
      for(int j=0; j<s2.length; j++) c.add([c[j]+1, p[j+1]+1, p[j]+(s1[i]==s2[j]?0:1)].reduce((a,b)=>a<b?a:b));
      p = c;
    }
    return 1.0 - (p.last / (s1.length > s2.length ? s1.length : s2.length));
  }

  void _scrollToIndex(int i) => Future.delayed(const Duration(milliseconds: 200), () { if(_itemScrollController.isAttached) _itemScrollController.scrollTo(index: i, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); });

  void _advanceAfterEval() {
    if (_currentStep > _sessionAyats.length) {
       _pauseListening();
       setState(() {
         _isCalculatingScore = true;
       });
       // Beri jeda 1.5 detik agar animasi ayat terakhir selesai dan terasa lebih halus
       Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
             setState(() { _isCalculatingScore = false; });
             _finishTest();
          }
       });
    } else {
        _scrollToIndex(_currentStep - 1);
        _pauseListening(); 
        
        // Restart mic automatically with optimized delay
        Future.delayed(const Duration(milliseconds: 800), () {
           if (mounted && !_isFinished && !_isRetryingAyat) {
              _startListening(isRestart: false); 
           }
        });
    }
  }

  // ===== BUILD UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(widget.initialJuz != null ? 'Ujian Juz ${widget.initialJuz}' : 'Ujian Surah', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
            if (_sessionAyats.isNotEmpty) Text('${_sessionAyats[0]['surah_name'] ?? ""}', style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh_rounded, color: Colors.white70))
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(child: _buildSessionList()),
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = _sessionAyats.isEmpty ? 0 : _currentStep / _sessionAyats.length;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ayat ${_currentStep} dari ${_sessionAyats.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation(_gold), minHeight: 6)),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _sessionAyats.length,
      itemBuilder: (context, i) {
        final data = _sessionAyats[i];
        
        bool isSurahHeader = data['isFirstAyatOfSurah'] == true;
        bool isFilled = _ayatResult.containsKey(i);
        bool isError = _ayatErrors.containsKey(i);
        bool isCurrent = (_currentStep - 1 == i);

        return Column(
          children: [
            if (isSurahHeader) _buildSurahDivider(data['surah_id'] ?? 1, data['surah_name'] ?? "Surah Next"),
            if (isFilled) _buildAyatCard(i, data)
            else if (isError && !isCurrent) _buildFailedCard(i, data)
            else if (isCurrent) _buildLiveCard(i, data)
            else _buildEmptyCard(i, data),
          ],
        );
      },
    );
  }

  Widget _buildSurahDivider(int surahId, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SurahDecorativeHeader(
        surahNameLatin: name,
        surahNameArabic: SurahData.allSurahNamesArabic[surahId - 1],
        ayatCount: SurahData.surahAyatCount[surahId - 1],
        location: SurahData.surahType[surahId - 1],
        surahNumber: surahId
      ),
    );
  }

  Widget _buildAyatCard(int i, Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCircleNum(data['ayat'], _teal),
          const SizedBox(width: 16),
          Expanded(
            child: Text(data['arab'], textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(fontFamily: 'Amiri', fontSize: 24, color: Colors.white, height: 1.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(int i, Map data) {
    if (i != _currentStep - 1) return _buildEmptyCard(i, data, isCurrent: false);
    
    String speech = _liveSpeech.isEmpty ? (_ayatErrors[i] ?? "") : _liveSpeech;
    if (speech.isEmpty) return _buildEmptyCard(i, data, isCurrent: true);

    List<String> targetWords = data['arab'].toString().trim().split(RegExp(r'\s+'));
    String normSpeech = _normalizeArab(speech);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: _gold.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCircleNum(data['ayat'], _gold),
              const Expanded(
                child: Text(
                  "Target Ayat:",
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Target Text (Dimmed)
          Text(
            data['arab'],
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: Colors.white.withOpacity(0.3),
              height: 1.6,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
          // Actual Spoken Text (What the user UTTERED)
          Row(
            children: [
              const Icon(Icons.record_voice_over_rounded, color: _gold, size: 16),
              const SizedBox(width: 8),
              const Text("Bacaan Kamu:", style: TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.bold)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          _buildColoredSpeech(speech, data['arab'], isLive: _liveSpeech.isNotEmpty),
          if (_isRetryingAyat && i == _currentStep - 1) ...[
            _buildMissingWordsWarning(speech, data['arab']),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, color: Colors.redAccent, size: 14),
                  SizedBox(width: 6),
                  Text("KESEMPATAN TERAKHIR (Percobaan ke-2)", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColoredSpeech(String speech, String target, {bool isLive = true}) {
    if (speech.isEmpty) return const SizedBox();
    
    List<String> speechWords = speech.trim().split(RegExp(r'\s+'));
    List<String> targetWords = target.trim().split(RegExp(r'\s+'));
    
    // Normalize target words for comparison
    List<String> normTargetWords = targetWords.map((w) => _normalizeArab(w)).toList();
    
    return Text.rich(
      TextSpan(
        children: speechWords.map((word) {
          String normWord = _normalizeArab(word);
          bool isMatch = normTargetWords.contains(normWord);
          
          return TextSpan(
            text: '$word ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: isLive ? 24 : 22,
              color: isMatch ? (isLive ? Colors.white : Colors.white70) : Colors.redAccent,
              height: 1.8,
              fontWeight: isMatch ? FontWeight.bold : FontWeight.w900,
              decoration: isMatch ? TextDecoration.none : TextDecoration.underline,
              decorationColor: Colors.redAccent.withOpacity(0.5),
            ),
          );
        }).toList(),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildMissingWordsWarning(String speech, String target) {
    if (speech.isEmpty) return const SizedBox();
    
    List<String> speechWords = speech.trim().split(RegExp(r'\s+'));
    List<String> targetWords = target.trim().split(RegExp(r'\s+'));
    
    List<String> normSpeechWords = speechWords.map((w) => _normalizeArab(w)).toList();
    List<String> missingWords = [];
    
    for (String tWord in targetWords) {
      if (!normSpeechWords.contains(_normalizeArab(tWord))) {
        missingWords.add(tWord);
      }
    }

    if (missingWords.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ada kata yang terlewat / tidak terdengar:", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  missingWords.join("   "),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedCard(int i, Map data) {
    String speech = _ayatErrors[i] ?? "Hening / Tidak terdeteksi";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildCircleNum(data['ayat'], Colors.redAccent),
              const Expanded(
                child: Text(
                  "Seharusnya:",
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Target Text (Correct)
          Text(
            data['arab'],
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              color: Colors.white60,
              height: 1.6,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
          // Wrong Spoken Text (What the user ACTUALLY SAID)
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
              const SizedBox(width: 8),
              const Text("Bacaan Kamu:", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          _buildColoredSpeech(speech, data['arab'], isLive: false),
          _buildMissingWordsWarning(speech, data['arab']),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(int i, Map data, {bool isCurrent = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isCurrent ? _navyCard : _navyCard.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCurrent ? _gold.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _buildCircleNum(data['ayat'], isCurrent ? _gold : Colors.white24),
          const SizedBox(width: 20),
          const Expanded(child: Opacity(opacity: 0.1, child: Text('................................', style: TextStyle(color: Colors.white, letterSpacing: 4)))),
        ],
      ),
    );
  }

  Widget _buildCircleNum(int n, Color c) {
    bool isDefaultDim = c == Colors.white24;
    Color circleColor = isDefaultDim ? const Color(0xFFD4AF37).withOpacity(0.4) : (c == _gold ? const Color(0xFFD4AF37) : c);
    Color txtColor = isDefaultDim ? Colors.white60 : (c == _gold ? const Color(0xFFFFD700) : c);
    
    return IslamicAyahSymbol(
      number: n,
      size: 36,
      color: circleColor,
      textColor: txtColor
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(color: _navyCard, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: _isFinished ? _buildFinishedControls() : _buildActiveControls(),
    );
  }

  Widget _buildActiveControls() {
    bool isListening = _recordStatus == RecordStatus.listening;
    bool hasError = _ayatErrors.containsKey(_currentStep - 1);
    
    String statusText = "";
    String subText = "";
    Color statusColor = Colors.white;

    if (_isCalculatingScore) {
       statusText = "✨ Alhamdulillah, Selesai!";
       subText = "Menyiapkan hasil evaluasi Anda...";
       statusColor = _gold;
    } else if (isListening) {
       statusText = _isRetryingAyat ? "🔄 Mengulang Bacaan..." : "Sistem Mendengar...";
       subText = "Silakan baca ayat ke-$_currentStep";
       statusColor = _isRetryingAyat ? Colors.orangeAccent : Colors.white;
    } else if (_isRetryingAyat) {
       statusText = "🔄 Kesempatan Mengulang (1x)";
       subText = "Ketuk mic untuk ulangi ayat ke-$_currentStep";
       statusColor = Colors.orangeAccent;
    } else if (hasError) {
       statusText = "❌ Bacaan salah";
       subText = "Flashback habis. Ketuk mic untuk lanjut";
       statusColor = Colors.redAccent;
    } else {
       statusText = "Mic Mati";
       subText = "Ketuk mic untuk membaca ayat ke-$_currentStep";
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _isCalculatingScore ? null : _toggleMic,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              double scale = isListening || _isCalculatingScore ? 1.0 + (_pulseController.value * 0.15) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: _isCalculatingScore ? _gold : (isListening ? Colors.red : (_isRetryingAyat ? Colors.orangeAccent : _gold)), 
                    boxShadow: [
                      BoxShadow(
                        color: (_isCalculatingScore ? _gold : (isListening ? Colors.red : _gold)).withOpacity(isListening || _isCalculatingScore ? 0.2 + (_pulseController.value * 0.3) : 0.3), 
                        blurRadius: isListening || _isCalculatingScore ? 15 + (_pulseController.value * 10) : 12, 
                        offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: _isCalculatingScore 
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: _navy, strokeWidth: 3),
                      )
                    : Icon(
                        isListening ? Icons.pause_rounded : (_isRetryingAyat ? Icons.replay_rounded : Icons.mic_rounded), 
                        color: Colors.white, size: 28,
                      ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        if (!_isCalculatingScore)
          IconButton(onPressed: _stopListening, icon: const Icon(Icons.stop_rounded, color: Colors.white54, size: 32))
      ],
    );
  }

  Widget _buildFinishedControls() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(backgroundColor: _gold, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('KEMBALI KE MENU', style: TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _showEvaluationModal(double acc) {
    int stars = acc >= 85 ? 3 : (acc >= 70 ? 2 : (acc >= 50 ? 1 : 0));
    
    // Logika Next Lesson
    int? nextSurah;
    int? nextJuz;
    String nextLabel = "";

    if (widget.initialJuz != null && widget.initialJuz! < 30) {
      nextJuz = widget.initialJuz! + 1;
      nextLabel = "Juz $nextJuz";
    } else if (widget.initialSurah != null && widget.initialSurah! < 114) {
      nextSurah = widget.initialSurah! + 1;
      nextLabel = SurahData.allSurahNames[nextSurah - 1];
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: _navy, 
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('HASIL EVALUASI', style: TextStyle(color: Colors.white60, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('${acc.toStringAsFixed(1)}%', style: const TextStyle(color: _gold, fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, color: _gold, size: 52))),
            const SizedBox(height: 32),
            
            // Button: Lanjut ke Surah/Juz Berikutnya (Hanya jika dapat bintang 3)
            if (nextLabel.isNotEmpty && stars == 3) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Tutup modal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => JuzTestScreen(initialSurah: nextSurah, initialJuz: nextJuz))
                    );
                  },
                  icon: const Icon(Icons.skip_next_rounded, color: _navy),
                  label: Text('LANJUT KE $nextLabel', style: const TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold, 
                    padding: const EdgeInsets.symmetric(vertical: 18), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Button: Selesai / Kembali ke Menu
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: const Text('KEMBALI KE MENU', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
