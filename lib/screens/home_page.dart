import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;
  final List<Course> apiCourses;

  const HomePage({
    super.key,
    required this.onCourseTap,
    this.apiCourses = const [],
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

        // 22. Tampilkan code, title, dan status minimal tiga course pada UI (Tahap 3)
        if (apiCourses.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.hub_outlined, color: primaryBlue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tahap 3: Model Course (REST API)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...apiCourses.take(3).map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              course.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: darkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: darkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: course.status == 'done'
                                  ? const Color(0xFFE8F5E9)
                                  : course.status == 'active'
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: course.status == 'done'
                                    ? const Color(0xFF2E7D32)
                                    : course.status == 'active'
                                        ? primaryBlue
                                        : const Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

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
