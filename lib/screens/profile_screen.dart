import 'package:flutter/material.dart';

import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../widgets/profile_card.dart';

/// Layar untuk melihat dan mengubah data profil mahasiswa.
class ProfileScreen extends StatefulWidget {
  /// Membuat instance [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _prodiController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final student = AppProvider.of(context).student;
      _nameController = TextEditingController(text: student.name);
      _nimController = TextEditingController(text: student.nim);
      _prodiController = TextEditingController(text: student.programStudi);
      _emailController = TextEditingController(text: student.email);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final provider = AppProvider.of(context);
    final updatedStudent = provider.student.copyWith(
      name: Validators.sanitize(_nameController.text),
      nim: Validators.sanitize(_nimController.text),
      programStudi: Validators.sanitize(_prodiController.text),
      email: Validators.sanitize(_emailController.text),
    );

    provider.updateStudent(updatedStudent);
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mahasiswa berhasil diperbarui.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = AppProvider.of(context).student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileCard(student: student),
            const SizedBox(height: 16),
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                ),
              )
            else
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ubah Data Profil',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) =>
                              Validators.validateTextField(v, 'Nama'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nimController,
                          decoration: const InputDecoration(
                            labelText: 'NIM',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) => Validators.validateTextField(
                            v,
                            'NIM',
                            minLength: 5,
                            maxLength: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _prodiController,
                          decoration: const InputDecoration(
                            labelText: 'Program Studi',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          validator: (v) =>
                              Validators.validateTextField(v, 'Program Studi'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _isEditing = false),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _saveProfile,
                                child: const Text('Simpan'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
