// ==========================================================
// Import paket (library) yang dibutuhkan
// ==========================================================

// Paket utama Flutter untuk membuat tampilan UI
import 'package:flutter/material.dart';

// Paket untuk fitur pengenalan suara (speech-to-text)
// Digunakan agar aplikasi bisa "mendengar" dan mengubah suara menjadi teks.
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Paket permission_handler digunakan untuk meminta izin ke sistem,
// misalnya izin menggunakan mikrofon, kamera, lokasi, dsb.
import 'package:permission_handler/permission_handler.dart';


// ==========================================================
// Membuat class utama untuk halaman Uji Hafalan Suara
// ==========================================================

class UjiSuaraScreen extends StatefulWidget {
  const UjiSuaraScreen({super.key});

  @override
  State<UjiSuaraScreen> createState() => _UjiSuaraScreenState();
}


// ==========================================================
// StatefulWidget artinya tampilan bisa berubah seiring waktu
// (misalnya ketika mulai atau berhenti mendengarkan suara)
// ==========================================================

class _UjiSuaraScreenState extends State<UjiSuaraScreen> {

  // Membuat variabel untuk mengakses fitur speech-to-text
  late stt.SpeechToText _speech;

  // Menyimpan status apakah sedang mendengarkan atau tidak
  bool _isListening = false;

  // Menyimpan hasil teks dari ucapan pengguna
  String _recognizedText = '';


  // ==========================================================
  // Fungsi initState dijalankan pertama kali saat halaman ini dibuka
  // Cocok untuk inisialisasi awal seperti meminta izin mikrofon
  // ==========================================================
  @override
  void initState() {
    super.initState();

    // Membuat objek SpeechToText
    _speech = stt.SpeechToText();

    // Meminta izin mikrofon agar bisa mendengarkan suara
    _requestMicrophonePermission();
  }


  // ==========================================================
  // Fungsi untuk meminta izin akses mikrofon dari pengguna
  // ==========================================================
  Future<void> _requestMicrophonePermission() async {
    // Mengecek status izin mikrofon
    var status = await Permission.microphone.status;

    // Jika belum diizinkan, tampilkan dialog permintaan izin
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }


  // ==========================================================
  // Fungsi untuk mulai atau berhenti mendengarkan suara pengguna
  // ==========================================================
  void _listen() async {
    // Jika belum sedang mendengarkan, maka mulai
    if (!_isListening) {

      // Menginisialisasi fitur speech-to-text
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'), // Menampilkan status di debug console
        onError: (error) => print('Error: $error'),     // Menampilkan error jika ada
      );

      // Jika fitur tersedia di perangkat
      if (available) {
        setState(() => _isListening = true); // Ubah status jadi "mendengarkan"

        // Mulai mendengarkan suara pengguna
        _speech.listen(
          onResult: (result) {
            // Ketika ada hasil suara yang dikenali, simpan ke variabel teks
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
          localeId: 'id_ID', // Gunakan bahasa Indonesia (bisa ubah ke 'ar_SA' untuk Arab)
        );
      }

    } else {
      // Jika sedang mendengarkan, maka hentikan
      setState(() => _isListening = false);
      _speech.stop(); // Berhenti mendengarkan
    }
  }


  // ==========================================================
  // Fungsi build() menampilkan tampilan halaman ke layar
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna latar belakang halaman
      backgroundColor: Colors.white,

      // ======================================================
      // AppBar (bagian atas halaman)
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700, // Warna hijau toska gelap
        title: const Text(
          'Uji Hafalan Suara',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Teks di tengah
        elevation: 4, // Sedikit bayangan di bawah AppBar
        shadowColor: Colors.teal.shade200,
      ),


      // ======================================================
      // Bagian isi (body) halaman
      // ======================================================
      body: Column(
        children: [

          // --------------------------------------------------
          // Header islami di bagian atas (hiasan + instruksi)
          // --------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: BoxDecoration(
              // Gradien warna hijau (atas ke bawah)
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),

              // Ujung bawah melengkung
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),

              // Bayangan lembut di bawah
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            // Isi dari header
            child: Column(
              children: const [
                // Ikon mic besar
                Icon(Icons.mic, color: Colors.white, size: 60),
                SizedBox(height: 10),

                // Teks instruksi
                Text(
                  'Ucapkan ayat atau surah,\ndan teks akan muncul di bawah ini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),


          // --------------------------------------------------
          // Kotak hasil teks pengenalan suara
          // --------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade200),
              ),

              // Menampilkan hasil teks ucapan
              child: Text(
                _recognizedText.isEmpty
                    ? 'Belum ada suara terdeteksi...' // Jika belum ada hasil
                    : _recognizedText,                // Jika sudah ada hasil
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Amiri', // Font arabic-style
                  height: 1.6, // Spasi antarbaris
                ),
              ),
            ),
          ),


          const Spacer(), // Mengatur posisi agar tombol mic tetap di bawah


          // --------------------------------------------------
          // Tombol mic di tengah bawah layar
          // --------------------------------------------------
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton.icon(
              onPressed: _listen, // Jalankan fungsi dengar
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isListening ? Colors.redAccent : Colors.teal.shade600, // Warna berubah
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Membulat lembut
                ),
                elevation: 8, // Efek bayangan
                shadowColor: Colors.tealAccent,
              ),

              // Ikon di tombol
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic, // Berubah sesuai status
                size: 28,
                color: Colors.white,
              ),

              // Teks di tombol
              label: Text(
                _isListening ? 'Berhenti Uji Suara' : 'Mulai Uji Suara',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
