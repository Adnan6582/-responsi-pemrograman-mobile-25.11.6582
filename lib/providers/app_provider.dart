import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/student.dart';
import '../repositories/note_repository.dart';

/// InheritedWidget untuk mendistribusikan state profil mahasiswa dan catatan kuliah.
class AppProvider extends InheritedWidget {
  /// Data profil mahasiswa saat ini.
  final Student student;

  /// Daftar catatan kuliah yang tersimpan.
  final List<Note> notes;

  /// Status proses pemuatan catatan dari penyimpanan lokal.
  final bool isLoadingNotes;

  /// Callback untuk memperbarui data profil mahasiswa.
  final void Function(Student) updateStudent;

  /// Callback untuk menambahkan catatan kuliah baru.
  final Future<void> Function(Note) addNote;

  /// Callback untuk menghapus catatan kuliah berdasarkan ID.
  final Future<void> Function(String) deleteNote;

  /// Membuat instance [AppProvider].
  const AppProvider({
    super.key,
    required this.student,
    required this.notes,
    required this.isLoadingNotes,
    required this.updateStudent,
    required this.addNote,
    required this.deleteNote,
    required super.child,
  });

  /// Mengambil instance [AppProvider] terdekat dari widget tree.
  static AppProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di context.');
    return provider!;
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return student != oldWidget.student ||
        notes != oldWidget.notes ||
        isLoadingNotes != oldWidget.isLoadingNotes;
  }
}

/// StatefulWidget pembungkus yang mengelola perubahan state aplikasi secara terkontrol.
class AppProviderWrapper extends StatefulWidget {
  /// Widget turunan yang akan menerima akses ke [AppProvider].
  final Widget child;

  /// Membuat instance [AppProviderWrapper].
  const AppProviderWrapper({super.key, required this.child});

  @override
  State<AppProviderWrapper> createState() => _AppProviderWrapperState();
}

class _AppProviderWrapperState extends State<AppProviderWrapper> {
  final NoteRepository _noteRepository = NoteRepository();

  Student _student = const Student(
    name: 'Budi Santoso',
    nim: '22.11.4567',
    programStudi: 'S1 Informatika',
    email: 'budi.santoso@students.amikom.ac.id',
  );

  List<Note> _notes = [];
  bool _isLoadingNotes = true;

  @override
  void initState() {
    super.initState();
    _loadInitialNotes();
  }

  Future<void> _loadInitialNotes() async {
    try {
      final loadedNotes = await _noteRepository.getAllNotes();
      if (!mounted) return;
      setState(() {
        _notes = loadedNotes;
        _isLoadingNotes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingNotes = false;
      });
    }
  }

  void _updateStudent(Student updatedStudent) {
    setState(() {
      _student = updatedStudent;
    });
  }

  Future<void> _addNote(Note note) async {
    await _noteRepository.addNote(note);
    final updatedNotes = await _noteRepository.getAllNotes();
    if (!mounted) return;
    setState(() {
      _notes = updatedNotes;
    });
  }

  Future<void> _deleteNote(String id) async {
    await _noteRepository.deleteNote(id);
    if (!mounted) return;
    setState(() {
      _notes = _notes.where((note) => note.id != id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      student: _student,
      notes: _notes,
      isLoadingNotes: _isLoadingNotes,
      updateStudent: _updateStudent,
      addNote: _addNote,
      deleteNote: _deleteNote,
      child: widget.child,
    );
  }
}
