//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormPage extends StatefulWidget {
  final Course? course;

  const CourseFormPage({super.key, this.course});

  bool get isEditing => course != null;

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;
  late String _selectedStatus;
  bool _isSaving = false;

  final List<String> _statusOptions = const ['planned', 'active', 'done'];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.course?.code ?? '');
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _creditsController = TextEditingController(
      text: widget.course != null ? widget.course!.credits.toString() : '',
    );
    _selectedStatus = (widget.course != null &&
            _statusOptions.contains(widget.course!.status))
        ? widget.course!.status
        : 'planned';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final code = _codeController.text.trim();
    final title = _titleController.text.trim();
    final credits = int.parse(_creditsController.text.trim());

    try {
      if (widget.isEditing) {
        final updatedCourse = Course(
          id: widget.course!.id,
          code: widget.course!.code,
          title: title,
          credits: credits,
          status: _selectedStatus,
          category: widget.course!.category,
        );
        final courseId = widget.course!.id ?? 1;
        await context
            .read<CourseProvider>()
            .updateCourse(courseId, updatedCourse);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course berhasil diperbarui!'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, updatedCourse);
      } else {
        final newCourse = Course(
          code: code,
          title: title,
          credits: credits,
          status: _selectedStatus,
          category: 'Computer Science',
        );
        final created =
            await context.read<CourseProvider>().createCourse(newCourse);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course berhasil ditambahkan!'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, created);
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan course: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Course' : 'Tambah Course';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identitas Mahasiswa Banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCE0F5)),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.isEditing
                          ? 'Tahap 16 — Course Data Manager: Edit Course'
                          : 'Tahap 16 — Course Data Manager: Tambah Course',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '$studentId • $studentName',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Code field
              TextFormField(
                controller: _codeController,
                readOnly: widget.isEditing,
                decoration: InputDecoration(
                  labelText: widget.isEditing
                      ? 'Kode Course (Read-only)'
                      : 'Kode Course',
                  hintText: 'Contoh: MOB01',
                  prefixIcon: Icon(
                    widget.isEditing ? Icons.lock_outline : Icons.code,
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      widget.isEditing ? const Color(0xFFF1F5F9) : Colors.white,
                  helperText: widget.isEditing
                      ? 'Kode tidak dapat diubah (kunci favorites)'
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode course wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Course',
                  hintText: 'Contoh: Flutter UI Fundamentals',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul course wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Credits field
              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah SKS (Credits)',
                  hintText: 'Contoh: 3',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Credits wajib diisi';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Credits harus berupa angka positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status field
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Course',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStatus = val;
                          });
                        }
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : widget.isEditing
                            ? 'Simpan Perubahan'
                            : 'Simpan Course',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

