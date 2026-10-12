import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;

  const HomePage({
    super.key,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Topi Toga (Graduation Cap)
            const Icon(
              Icons.school,
              size: 80,
              color: Color(0xFF232B38),
            ),
            const SizedBox(height: 18),

            // Judul Course Explorer
            const Text(
              'Course Explorer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Deskripsi Aplikasi
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'E-LEARNING.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),

            // Card Identitas Mahasiswa
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Text(
                    'Identitas Mahasiswa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nama: $studentName',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'NIM: $studentId',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Tampilkan Info
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
                          Icon(Icons.info_outline, color: primaryBlue),
                          SizedBox(width: 8),
                          Text('Informasi'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Course Explorer',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Aplikasi pembelajaran Flutter UI Fundamentals.'),
                          const Divider(height: 20),
                          Text('Nama: $studentName'),
                          Text('NIM: $studentId'),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final sampleCourse = Course.fromJson(courses.first);
                              return Text(
                                'Sample Model: ${sampleCourse.title} (${sampleCourse.code})',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              );
                            },
                          ),
                          Consumer<CourseProvider>(
                            builder: (context, state, _) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('Favorit: ${state.favorites.length} course'),
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
              icon: const Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFF475569),
              ),
              label: const Text(
                'Tampilkan Info',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
