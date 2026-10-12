import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';
class CourseService {
  // 67. Kasus C: Dukungan simulasi error untuk pengujian error state
  Future<List<Course>> loadCourses({bool simulateError = false}) async {
    if (simulateError) {
      throw Exception('Gagal memuat data dari CourseService (Simulasi Kasus C)');
    }
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
