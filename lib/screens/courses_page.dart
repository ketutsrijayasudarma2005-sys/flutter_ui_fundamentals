import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class CoursesPage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;

  const CoursesPage({
    super.key,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseProvider>();

    if (courseState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (courseState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Terjadi kesalahan:\n${courseState.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<CourseProvider>().loadCourses();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final courseModels = courseState.courses.isNotEmpty
        ? courseState.courses
        : courses.map((json) => Course.fromJson(json)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courseModels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 155,
          ),
          itemBuilder: (context, index) {
            final course = courseModels[index];
            return CourseCard(
              course: course,
              onTap: () => onCourseTap(course),
            );
          },
        );
      },
    );
  }
}
