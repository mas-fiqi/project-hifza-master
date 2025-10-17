// lib/services/compare_text_service.dart

class CompareTextService {
  /// Fungsi utama untuk membandingkan dua teks (hafalan vs teks asli)
  /// Akan menghasilkan skor kecocokan antara 0 - 100
  double compareTexts(String original, String userInput) {
    if (original.isEmpty || userInput.isEmpty) return 0;

    // Ubah ke huruf kecil semua dan hapus tanda baca
    String cleanOriginal = _cleanText(original);
    String cleanInput = _cleanText(userInput);

    // Pecah jadi kata-kata
    List<String> originalWords = cleanOriginal.split(' ');
    List<String> inputWords = cleanInput.split(' ');

    int matchCount = 0;

    for (String word in inputWords) {
      if (originalWords.contains(word)) {
        matchCount++;
      }
    }

    // Hitung skor (persentase kecocokan)
    double similarity = (matchCount / originalWords.length) * 100;
    return double.parse(similarity.toStringAsFixed(2));
  }

  /// Membersihkan teks dari tanda baca dan spasi berlebihan
  String _cleanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // hapus tanda baca
        .replaceAll(RegExp(r'\s+'), ' ')   // hapus spasi ganda
        .trim();
  }
}
