import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;

  const HomePage({
    super.key,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseProvider>();
    final courseModels = courseState.courses.isNotEmpty
        ? courseState.courses
        : courses.map((json) => Course.fromJson(json)).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Top Banner NIM • Nama Mahasiswa (sesuai gambar Course Explorer v2)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [
              Text(
                'Identitas Mahasiswa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$studentId • $studentName',
                style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2),
              Text(
                'Nama: $studentName',
                style: TextStyle(color: Color(0xFF334155), fontSize: 12),
              ),
              Text(
                'NIM: $studentId',
                style: TextStyle(color: Color(0xFF334155), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Summary Cards: Courses & Favorites (62. Shared state)
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Courses',
                value: '${courseModels.length}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Favorites',
                value: '${courseState.favorites.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Icon Topi Toga & Judul Course Explorer
        Center(
          child: Column(
            children: [
              const Icon(
                Icons.school,
                size: 60,
                color: Color(0xFF232B38),
              ),
              const SizedBox(height: 6),
              const Text(
                'Course Explorer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.school, color: primaryBlue),
                            SizedBox(width: 8),
                            Text('Informasi'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Course Explorer v2',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Aplikasi pembelajaran Flutter UI Fundamentals.',
                            ),
                            const Divider(height: 20),
                            const Text(
                              'Identitas Mahasiswa',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Nama: $studentName'),
                            Text('NIM: $studentId'),
                            const SizedBox(height: 8),
                            Consumer<CourseProvider>(
                              builder: (context, state, _) {
                                return Text(
                                  'Favorit: ${state.favorites.length} course',
                                );
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Tutup'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('Tampilkan Info'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Daftar Course Cards (sesuai gambar Course Explorer v2)
        ...courseModels.map(
          (course) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CourseCard(
              course: course,
              onTap: () => onCourseTap(course),
              compact: true,
            ),
          ),
        ),
      ],
    );
  }
}
