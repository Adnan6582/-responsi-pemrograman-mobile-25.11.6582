/// Kelas utilitas untuk validasi dan sanitasi input pengguna.
class Validators {
  /// Membersihkan karakter berbahaya (`<`, `>`, `"`, `'`) dari input teks.
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>"\x27]'), '').trim();
  }

  /// Memvalidasi judul catatan: minimal 3 karakter dan maksimal 50 karakter.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul catatan tidak boleh kosong';
    }
    final cleanValue = sanitize(value);
    if (cleanValue.length < 3) {
      return 'Judul minimal 3 karakter';
    }
    if (cleanValue.length > 50) {
      return 'Judul maksimal 50 karakter';
    }
    return null;
  }

  /// Memvalidasi isi catatan: minimal 10 karakter dan maksimal 1000 karakter.
  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Isi catatan tidak boleh kosong';
    }
    final cleanValue = sanitize(value);
    if (cleanValue.length < 10) {
      return 'Isi catatan minimal 10 karakter';
    }
    if (cleanValue.length > 1000) {
      return 'Isi catatan maksimal 1000 karakter';
    }
    return null;
  }

  /// Memvalidasi field teks umum pada profil mahasiswa.
  static String? validateTextField(
    String? value,
    String fieldName, {
    int minLength = 3,
    int maxLength = 80,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final cleanValue = sanitize(value);
    if (cleanValue.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    if (cleanValue.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  /// Memvalidasi format alamat email mahasiswa.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final cleanValue = sanitize(value);
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(cleanValue)) {
      return 'Format email tidak valid';
    }
    return null;
  }
}
