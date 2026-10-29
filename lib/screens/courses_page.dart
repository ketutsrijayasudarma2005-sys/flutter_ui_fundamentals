import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';

class CoursesPage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;

  const CoursesPage({
    super.key,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    // 1. Loading State
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State dengan widget ErrorView
    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: provider.loadCourses,
      );
    }

    // 3. Empty State
    if (provider.courses.isEmpty) {
      return const Center(child: Text('Data course belum tersedia'));
    }

    // 4. Success State
    final courseModels = provider.courses;

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
