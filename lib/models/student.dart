/// Model data yang merepresentasikan profil mahasiswa.
class Student {
  /// Nama lengkap mahasiswa.
  final String name;

  /// Nomor Induk Mahasiswa (NIM).
  final String nim;

  /// Program studi mahasiswa.
  final String programStudi;

  /// Alamat email institusi atau pribadi mahasiswa.
  final String email;

  /// Membuat instance baru dari [Student].
  const Student({
    required this.name,
    required this.nim,
    required this.programStudi,
    required this.email,
  });

  /// Menghasilkan inisial maksimal 2 huruf kapital dari [name] untuk avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  /// Membuat salinan [Student] dengan pembaruan pada field tertentu.
  Student copyWith({
    String? name,
    String? nim,
    String? programStudi,
    String? email,
  }) {
    return Student(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
    );
  }
}
