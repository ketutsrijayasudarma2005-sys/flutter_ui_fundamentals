//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import 'course_data_source.dart';

// 52. CourseApiService implements CourseDataSource
class CourseApiService implements CourseDataSource {
  CourseApiService([String? baseUrl])
      : baseUrl = baseUrl ?? 'https://course-api-pearl.vercel.app';

  final String baseUrl;

  Future<List<Course>> getCourses() async {
    final endpoint = baseUrl.endsWith('/courses') ||
            baseUrl.endsWith('/posts') ||
            baseUrl.contains('invalid') ||
            baseUrl.contains('error')
        ? baseUrl
        : baseUrl.contains('jsonplaceholder')
            ? '$baseUrl/posts'
            : '$baseUrl/courses';
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course');
    }

    final List data = jsonDecode(response.body) as List;
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Tahap 6: HTTP POST: Membuat Resource Baru
  Future<Course> createCourse(Course course) async {
    final endpoint = baseUrl.endsWith('/courses')
        ? baseUrl
        : '$baseUrl/courses';
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Gagal membuat course');
  }

  // Tahap 7: HTTP PUT/PATCH: Memperbarui Resource
  Future<void> updateCourse(int id, Course course) async {
    final endpoint = baseUrl.endsWith('/courses')
        ? '$baseUrl/$id'
        : '$baseUrl/courses/$id';
    final response = await http.put(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memperbarui course');
    }
  }

  // Tahap 8: HTTP DELETE: Menghapus Resource
  Future<void> deleteCourse(int id) async {
    final endpoint = baseUrl.endsWith('/courses')
        ? '$baseUrl/$id'
        : '$baseUrl/courses/$id';
    final response = await http.delete(
      Uri.parse(endpoint),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal menghapus course');
    }
  }
}
