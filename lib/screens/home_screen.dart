import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/note.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'note_form_screen.dart';
import 'profile_screen.dart';

/// Layar utama aplikasi yang menampilkan ringkasan profil, daftar catatan, dan referensi API.
class HomeScreen extends StatefulWidget {
  /// Membuat instance [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _apiPosts = [];
  bool _isLoadingApi = true;
  String? _apiErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReferencePosts();
  }

  /// Mengambil data referensi dari API publik menggunakan HTTP GET dengan error handling.
  Future<void> _fetchReferencePosts() async {
    setState(() {
      _isLoadingApi = true;
      _apiErrorMessage = null;
    });

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/posts?_limit=10');
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (AppConfig.apiKey.isNotEmpty) 'X-API-Key': AppConfig.apiKey,
            },
          )
          .timeout(const Duration(seconds: 10));

      // Logging aman: hanya mencatat status HTTP, tidak pernah mencetak API_KEY atau konten sensitif.
      debugPrint('HTTP GET /posts status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _apiPosts = decoded;
          _isLoadingApi = false;
        });
      } else {
        throw HttpException(
          'Server mengembalikan status ${response.statusCode}',
        );
      }
    } on TimeoutException {
      debugPrint('HTTP GET /posts gagal: Timeout.');
      if (!mounted) return;
      setState(() {
        _isLoadingApi = false;
        _apiErrorMessage = 'Koneksi timeout. Periksa jaringan Anda.';
      });
    } on SocketException {
      debugPrint('HTTP GET /posts gagal: Tidak ada koneksi internet.');
      if (!mounted) return;
      setState(() {
        _isLoadingApi = false;
        _apiErrorMessage = 'Tidak ada koneksi internet.';
      });
    } catch (e) {
      debugPrint('HTTP GET /posts gagal: Terjadi kesalahan jaringan.');
      if (!mounted) return;
      setState(() {
        _isLoadingApi = false;
        _apiErrorMessage = 'Gagal memuat data referensi dari server.';
      });
    }
  }

  Future<void> _navigateToAddNote() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NoteFormScreen()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan terenkripsi.')),
      );
    }
  }

  void _showNoteDetailDialog(Note note) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(child: Text(note.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Apakah Anda yakin ingin menghapus "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AppProvider.of(context).deleteNote(note.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Catatan telah dihapus.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppProvider.of(context);
    final student = provider.student;
    final notes = provider.notes;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catatan Kuliah'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Profil Mahasiswa',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.note_outlined), text: 'Catatan Saya'),
              Tab(icon: Icon(Icons.public_outlined), text: 'Info Kampus'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Ringkasan Profil Mahasiswa di Bagian Atas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Text(student.initials),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'NIM: ${student.nim}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: const Text('Detail'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Daftar Catatan Kuliah Lokal Terenkripsi
                  _buildNotesTab(provider.isLoadingNotes, notes),
                  // Tab 2: Daftar Referensi dari HTTP GET API Publik
                  _buildApiTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToAddNote,
          icon: const Icon(Icons.add),
          label: const Text('Catatan'),
        ),
      ),
    );
  }

  Widget _buildNotesTab(bool isLoading, List<Note> notes) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notes.isEmpty) {
      return const EmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _showNoteDetailDialog(note),
          onDelete: () => _confirmDeleteNote(note),
        );
      },
    );
  }

  Widget _buildApiTab() {
    if (_isLoadingApi) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_apiErrorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchReferencePosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchReferencePosts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _apiPosts.length,
        itemBuilder: (context, index) {
          final item = _apiPosts[index] as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(child: Text('${item['id']}')),
              title: Text(
                item['title'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item['body'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
