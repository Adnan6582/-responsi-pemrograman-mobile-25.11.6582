/// Model data yang merepresentasikan catatan kuliah.
class Note {
  /// Pengenal unik catatan.
  final String id;

  /// Judul catatan kuliah (disimpan sebagai metadata).
  final String title;

  /// Waktu pembuatan catatan (disimpan sebagai metadata).
  final DateTime createdAt;

  /// Isi catatan kuliah (disimpan terenkripsi di Secure Storage).
  final String content;

  /// Membuat instance baru dari [Note].
  const Note({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.content,
  });

  /// Mengonversi hanya metadata catatan (`id`, `title`, `createdAt`) ke Map JSON.
  Map<String, dynamic> toMetadataJson() {
    return {'id': id, 'title': title, 'createdAt': createdAt.toIso8601String()};
  }

  /// Membuat objek [Note] dari metadata JSON dan [content] terdekripsi.
  factory Note.fromMetadataJson(
    Map<String, dynamic> json, {
    String content = '',
  }) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: content,
    );
  }
}
