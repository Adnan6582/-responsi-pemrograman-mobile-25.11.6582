import 'package:flutter/material.dart';

/// Widget tampilan kosong ketika belum ada catatan kuliah yang tersimpan.
class EmptyState extends StatelessWidget {
  /// Judul utama pesan kosong.
  final String title;

  /// Keterangan tambahan untuk mengarahkan pengguna.
  final String subtitle;

  /// Membuat instance [EmptyState].
  const EmptyState({
    super.key,
    this.title = 'Belum Ada Catatan Kuliah',
    this.subtitle = 'Tekan tombol + di bawah untuk menambahkan catatan baru.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
