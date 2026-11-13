import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Kelas konfigurasi aplikasi yang memuat variabel lingkungan dari file `.env`.
class AppConfig {
  /// Memuat file `.env` saat inisialisasi aplikasi.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('AppConfig: Konfigurasi lingkungan berhasil dimuat.');
    } catch (e) {
      debugPrint(
        'AppConfig: Gagal memuat file .env, menggunakan nilai default.',
      );
    }
  }

  /// Mengambil nilai `BASE_URL` dari `.env` tanpa hardcode kredensial.
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';

  /// Mengambil nilai `API_KEY` dari `.env` (tidak pernah dicetak ke log).
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}
