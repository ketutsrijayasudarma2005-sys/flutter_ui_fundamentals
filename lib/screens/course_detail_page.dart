import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'edit_course_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final activeCourse = provider.courses.firstWhere(
      (c) => c.code == course.code,
      orElse: () => course,
    );
    final courseCode = activeCourse.code;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
        actions: [
          // 41. Tombol Edit pada Course Detail
          IconButton(
            tooltip: 'Edit Course',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCoursePage(course: activeCourse),
                ),
              );
            },
          ),
          Consumer<CourseProvider>(
            builder: (context, state, child) {
              final isFavorite = state.isFavorite(courseCode);
              return IconButton(
                tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                onPressed: () {
                  context.read<CourseProvider>().toggleFavorite(courseCode);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : darkBlue,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            '$studentId • $studentName',
            textAlign: TextAlign.center,
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        activeCourse.title,
                        style: const TextStyle(
                          color: darkBlue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Consumer<CourseProvider>(
                      builder: (context, state, child) {
                        final isFavorite = state.isFavorite(courseCode);
                        return Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 28,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Kode: ${activeCourse.code}'),
                const SizedBox(height: 10),
                Text('SKS: ${activeCourse.credits}'),
                const SizedBox(height: 10),
                Text('Status: ${activeCourse.status}'),
                const SizedBox(height: 10),
                Text('Kategori: ${activeCourse.category}'),
                const SizedBox(height: 10),
                // 56. Tampilkan status favorite pada DetailPage
                Consumer<CourseProvider>(
                  builder: (context, state, child) {
                    final isFavorite = state.isFavorite(courseCode);
                    return Row(
                      children: [
                        const Text('Status Favorit: '),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                          child: Text(
                            isFavorite ? 'Favorit' : 'Bukan Favorit',
                            style: TextStyle(
                              color: isFavorite ? Colors.red : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer<CourseProvider>(
                  builder: (context, state, child) {
                    final isFavorite = state.isFavorite(courseCode);
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<CourseProvider>().toggleFavorite(courseCode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? 'Course dihapus dari favorit'
                                    : 'Course ditambahkan ke favorit',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Hapus dari Favorites'
                              : 'Tambah ke Favorites',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // 41. Tombol Edit pada Course Detail
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCoursePage(course: activeCourse),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
