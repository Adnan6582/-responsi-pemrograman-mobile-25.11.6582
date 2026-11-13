import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Layanan penyimpanan terenkripsi menggunakan `flutter_secure_storage`.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Membuat instance [SecureStorageService] dengan opsi enkripsi Android.
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  /// Membentuk kunci penyimpanan dengan format `note_content_<id>`.
  String _buildKey(String noteId) => 'note_content_$noteId';

  /// Menyimpan isi catatan secara terenkripsi berdasarkan [noteId].
  Future<void> saveContent(String noteId, String content) async {
    await _storage.write(key: _buildKey(noteId), value: content);
    debugPrint(
      'SecureStorage: Konten catatan berhasil disimpan (ID: $noteId).',
    );
  }

  /// Membaca isi catatan terenkripsi berdasarkan [noteId].
  Future<String?> getContent(String noteId) async {
    final content = await _storage.read(key: _buildKey(noteId));
    debugPrint('SecureStorage: Konten catatan dibaca (ID: $noteId).');
    return content;
  }

  /// Menghapus isi catatan terenkripsi berdasarkan [noteId].
  Future<void> deleteContent(String noteId) async {
    await _storage.delete(key: _buildKey(noteId));
    debugPrint('SecureStorage: Konten catatan dihapus (ID: $noteId).');
  }
}
