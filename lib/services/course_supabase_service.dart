//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

// 71. CourseSupabaseService implements CourseDataSource
class CourseSupabaseService implements CourseDataSource {
  CourseSupabaseService([SupabaseClient? client]) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get supabase => _client ?? Supabase.instance.client;

  // 72 & 73. Ambil data dari tabel courses dan konversi menjadi List<Course>
  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Sementara, agar kelas tetap dapat dikompilasi:
  @override
  Future<Course> createCourse(Course course) => throw UnimplementedError();

  @override
  Future<void> updateCourse(int id, Course course) => throw UnimplementedError();

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}
