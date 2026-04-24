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

class _JuzTestScreenState extends State<JuzTestScreen> {
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

  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadData();
    _initSpeech();
  }

  @override
  void dispose() {
    _isManualRecording = false;
    _speech.stop();
    _silenceTimer?.cancel();
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
          if (_isManualRecording && mounted && !_isFinished) {
             _sessionBuffer = ("$_sessionBuffer $_lastRecognizedWords").trim();
             _lastRecognizedWords = "";
             Future.delayed(const Duration(milliseconds: 500), () {
                if (_isManualRecording && mounted) _startListening(isRestart: true);
             });
          }
        },
        onStatus: (val) {
          if (val == 'done' && mounted && _isManualRecording && !_isFinished) {
             _sessionBuffer = ("$_sessionBuffer $_lastRecognizedWords").trim();
             _lastRecognizedWords = "";
             Future.delayed(const Duration(milliseconds: 500), () {
                if (_isManualRecording && mounted) _startListening(isRestart: true);
             });
          }
        },
      );
      if (available && mounted) {
        setState(() => _currentLocaleId = 'ar-SA');
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
        // Strict isolation: always clear buffer when not a continuous restart
        _sessionBuffer = "";
        _lastRecognizedWords = "";
        _liveSpeech = "";
        _startSilenceTimer();
      }
    });
    _speech.listen(
      onResult: (val) {
        if (_recordStatus != RecordStatus.listening) return; // Prevent ghost text after stop
        if (val.recognizedWords.isNotEmpty) {
          _lastRecognizedWords = val.recognizedWords;
          _secondsSinceLastWord = 0;
          _evaluateBuffer(forceFail: false);
        }
      },
      localeId: _currentLocaleId,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
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
    if (_currentStep > _sessionAyats.length) return;

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

    double simArab = _calculateSimilarity(_stripAlif(normArab), _stripAlif(targetArab));
    bool isMatch = simArab >= 0.88; // INCREASED SENSITIVITY

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
      setState(() {
        _ayatResult[idx] = target["arab"];
        _ayatErrors.remove(idx);
        _isRetryingAyat = false;
        _currentStep++;
        
        // Immediate buffer clear to prevent ghost text
        _sessionBuffer = "";
        _lastRecognizedWords = "";
        _liveSpeech = "";
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

  // ===== NORMALIZERS & MATH =====
  String _normalizeArab(String t) => t.replaceAll(RegExp(r'[^\u0621-\u064A]'), '').replaceAll(RegExp(r'[أإآٱ]'), 'ا').replaceAll('ى', 'ي').replaceAll('ة', 'ه');
  String _stripAlif(String t) => t.replaceAll('ا', '');
  String _normalizeLatin(String t) => t.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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
       _finishTest();
    } else {
       _scrollToIndex(_currentStep - 1);
       _pauseListening(); // Force STT engine buffer to clear
       
       // Restart mic automatically for the next ayah if not in manual retry mode
       Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isFinished && !_isRetryingAyat) {
             _startListening(isRestart: false); // Starts with completely clean buffer
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
    
    // Fallback jika belum bicara apa-apa
    if (speech.isEmpty) return _buildEmptyCard(i, data, isCurrent: true);

    List<String> speechWords = speech.split(RegExp(r'\s+'));
    List<String> targetWords = data['arab'].toString().split(RegExp(r'\s+'));
    
    List<TextSpan> spans = [];
    for (String sw in speechWords) {
      if (sw.isEmpty) continue;
      String normSw = _stripAlif(_normalizeArab(sw));
      
      bool isMatch = false;
      for (String tw in targetWords) {
        String normTw = _stripAlif(_normalizeArab(tw));
        if (normTw == normSw || _calculateSimilarity(normSw, normTw) >= 0.85) {
          isMatch = true;
          break;
        }
      }
      
      spans.add(TextSpan(
        text: "$sw ",
        style: TextStyle(
          color: isMatch ? _teal : Colors.redAccent,
          fontFamily: 'Amiri',
          fontSize: 24,
          height: 1.8,
          fontWeight: isMatch ? FontWeight.bold : FontWeight.normal
        )
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCircleNum(data['ayat'], _gold),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              text: TextSpan(children: spans),
            ),
          ),
          const Icon(Icons.keyboard_voice_rounded, color: _gold, size: 20),
        ],
      ),
    );
  }

  Widget _buildFailedCard(int i, Map data) {
    String speech = _ayatErrors[i] ?? "Hening / Tidak terdeteksi";
    
    List<String> speechWords = speech.split(RegExp(r'\s+'));
    List<String> targetWords = data['arab'].toString().split(RegExp(r'\s+'));
    
    List<TextSpan> spans = [];
    for (String sw in speechWords) {
      if (sw.isEmpty) continue;
      String normSw = _stripAlif(_normalizeArab(sw));
      
      bool isMatch = false;
      for (String tw in targetWords) {
        String normTw = _stripAlif(_normalizeArab(tw));
        if (normTw == normSw || _calculateSimilarity(normSw, normTw) >= 0.85) {
          isMatch = true;
          break;
        }
      }
      
      spans.add(TextSpan(
        text: "$sw ",
        style: TextStyle(
          color: isMatch ? _teal : Colors.redAccent,
          fontFamily: 'Amiri',
          fontSize: 24,
          height: 1.8,
          fontWeight: isMatch ? FontWeight.bold : FontWeight.normal
        )
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCircleNum(data['ayat'], Colors.redAccent),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              text: TextSpan(children: spans),
            ),
          ),
          const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
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

    if (isListening) {
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
          onTap: _toggleMic,
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: isListening ? Colors.red : (_isRetryingAyat ? Colors.orangeAccent : _gold), 
              boxShadow: [BoxShadow(color: (isListening ? Colors.red : _gold).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
            ),
            child: Icon(
              isListening ? Icons.pause_rounded : (_isRetryingAyat ? Icons.replay_rounded : Icons.mic_rounded), 
              color: Colors.white, size: 28,
            ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: _navy, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SKOR AKHIR', style: TextStyle(color: Colors.white60, letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 8),
            Text('${acc.toStringAsFixed(1)}%', style: const TextStyle(color: _gold, fontSize: 42, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, color: _gold, size: 48))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=>Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: _teal, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('LANJUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}
