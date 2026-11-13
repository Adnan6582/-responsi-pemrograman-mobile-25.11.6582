import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../services/secure_storage_service.dart';

/// Repository yang mengelola pemisahan penyimpanan metadata dan isi catatan.
class NoteRepository {
  static const String _metadataListKey = 'notes_metadata_list';
  final SecureStorageService _secureStorageService;

  /// Membuat instance [NoteRepository].
  NoteRepository({SecureStorageService? secureStorageService})
    : _secureStorageService = secureStorageService ?? SecureStorageService();

  /// Mengambil seluruh daftar catatan (metadata dari SharedPreferences & isi dari SecureStorage).
  Future<List<Note>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_metadataListKey) ?? [];

    final List<Note> notes = [];
    for (final rawItem in rawList) {
      final Map<String, dynamic> map =
          jsonDecode(rawItem) as Map<String, dynamic>;
      final id = map['id'] as String;
      final encryptedContent = await _secureStorageService.getContent(id) ?? '';
      notes.add(Note.fromMetadataJson(map, content: encryptedContent));
    }

    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    debugPrint('NoteRepository: Berhasil memuat ${notes.length} catatan.');
    return notes;
  }

  /// Menyimpan catatan baru: isi ke SecureStorage dan metadata ke SharedPreferences.
  Future<void> addNote(Note note) async {
    await _secureStorageService.saveContent(note.id, note.content);

    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_metadataListKey) ?? [];
    rawList.add(jsonEncode(note.toMetadataJson()));
    await prefs.setStringList(_metadataListKey, rawList);

    debugPrint('NoteRepository: Catatan baru ditambahkan (ID: ${note.id}).');
  }

  /// Menghapus catatan dari SharedPreferences dan SecureStorage berdasarkan [id].
  Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_metadataListKey) ?? [];

    rawList.removeWhere((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return map['id'] == id;
    });

    await prefs.setStringList(_metadataListKey, rawList);
    await _secureStorageService.deleteContent(id);

    debugPrint('NoteRepository: Catatan dihapus (ID: $id).');
  }
}
