import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class FavoritesPage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;

  const FavoritesPage({
    super.key,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseProvider>();
    final courseModels = courseState.courses.isNotEmpty
        ? courseState.courses
        : courses.map((json) => Course.fromJson(json)).toList();
    final favoriteCourses = courseModels
        .where((course) => courseState.isFavorite(course.code))
        .toList();

    if (favoriteCourses.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada course favorit.',
          style: TextStyle(color: darkBlue, fontSize: 16),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Courses Favorit')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteCourses.length,
        itemBuilder: (context, index) {
          final course = favoriteCourses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CourseCard(
              course: course,
              onTap: () => onCourseTap(course),
              compact: true,
            ),
          );
        },
      ),
    );
  }
}
