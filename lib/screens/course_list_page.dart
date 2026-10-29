//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

class CourseListPage extends StatelessWidget {
  final ValueChanged<Course>? onCourseTap;

  const CourseListPage({super.key, this.onCourseTap});

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus course "${course.title}" (${course.code})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final courseId = course.id ?? 1;
        await context.read<CourseProvider>().deleteCourse(
              courseId,
              code: course.code,
            );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course berhasil dihapus!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus course: $e'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openDetail(BuildContext context, Course course) {
    if (onCourseTap != null) {
      onCourseTap!(course);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailPage(course: course),
        ),
      );
    }
  }

  void _openEdit(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseFormPage(course: course),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CourseFormPage(),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '$studentId • $studentName',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildAddCourseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCreate(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              '+ Tambah Course',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D652D),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context, course),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.code} • ${course.credits} SKS',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit Course',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF0284C7),
                ),
                onPressed: () => _openEdit(context, course),
              ),
              IconButton(
                tooltip: 'Hapus Course',
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF0284C7),
                ),
                onPressed: () => _confirmDelete(context, course),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Data Manager'),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : () => provider.loadCourses(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadCourses,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStudentHeader(),
              const SizedBox(height: 12),
              _buildAddCourseButton(context),
              const SizedBox(height: 16),

              // 1. Loading State
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              // 2. Error State & Retry
              else if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ErrorView(
                    message: provider.error!,
                    onRetry: provider.loadCourses,
                  ),
                )
              // 3. Empty State
              else if (provider.courses.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada data course di database',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tekan "+ Tambah Course" untuk menambahkan data baru.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              // 4. Success State (List of Courses)
              else
                ...provider.courses.map((c) => _buildCourseCard(context, c)),
            ],
          ),
        ),
      ),
    );
  }
}

