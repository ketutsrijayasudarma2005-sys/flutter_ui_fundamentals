import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool compact;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final courseCode = course.code;

    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          course.code,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                        const SizedBox(width: 6),
                        Text(
                          course.status,
                          style: const TextStyle(
                            color: greenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${course.code} • ${course.credits} SKS',
                        style: const TextStyle(
                          color: Color(0xFF536D87),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Consumer<CourseProvider>(
                builder: (context, state, child) {
                  final isFavorite = state.isFavorite(courseCode);
                  return IconButton(
                    tooltip: isFavorite
                        ? 'Hapus dari favorit'
                        : 'Tambah ke favorit',
                    onPressed: () {
                      context.read<CourseProvider>().toggleFavorite(courseCode);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? greenColor : darkBlue,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
