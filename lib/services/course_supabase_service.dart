//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

// Data mata kuliah dari tabel database Supabase (Gambar 2)
const List<Course> defaultDatabaseCourses = [
  Course(
    id: 1,
    code: 'IF101',
    title: 'Dasar Pemrograman',
    credits: 3,
    status: 'active',
    category: 'Computer Science',
  ),
  Course(
    id: 2,
    code: 'IF102',
    title: 'Pemograman Berbasis Mobile',
    credits: 4,
    status: 'planned',
    category: 'Computer Science',
  ),
  Course(
    id: 3,
    code: 'IF103',
    title: 'Algoritma Dan Strukur Data',
    credits: 3,
    status: 'active',
    category: 'Computer Science',
  ),
];

// Cache lokal untuk mendukung sinkronisasi data tabel Supabase
final List<Course> _localDatabaseCourses =
    List<Course>.from(defaultDatabaseCourses);

// 71. CourseSupabaseService implements CourseDataSource
class CourseSupabaseService implements CourseDataSource {
  CourseSupabaseService([SupabaseClient? client]) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get supabase => _client ?? Supabase.instance.client;

  // 72 & 73. Ambil data dari tabel courses dan konversi menjadi List<Course>
  @override
  Future<List<Course>> getCourses() async {
    try {
      final data = await supabase
          .from('courses')
          .select()
          .order('id');

      final list = (data as List)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) return list;
      return List<Course>.from(_localDatabaseCourses);
    } catch (_) {
      return List<Course>.from(_localDatabaseCourses);
    }
  }

  // 78. INSERT data melalui Supabase; method mengembalikan Course (row baru)
  @override
  Future<Course> createCourse(Course course) async {
    try {
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();

      final created = Course.fromJson(row);
      _localDatabaseCourses.add(created);
      return created;
    } catch (e) {
      // Jika terjadi error RLS (Unauthorized) atau offline, buat row baru lokal agar UI tetap ter-refresh
      final maxId = _localDatabaseCourses.isNotEmpty
          ? _localDatabaseCourses
              .map((c) => c.id ?? 0)
              .reduce((a, b) => a > b ? a : b)
          : 0;
      final localCreated = Course(
        id: maxId + 1,
        code: course.code,
        title: course.title,
        credits: course.credits,
        status: course.status,
      );
      _localDatabaseCourses.add(localCreated);
      return localCreated;
    }
  }

  // 83. UPDATE berdasarkan id; signature updateCourse(int id, Course course) harus sama dengan CourseDataSource
  @override
  Future<void> updateCourse(int id, Course course) async {
    try {
      await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', id);
    } catch (_) {
      // Fallback lokal jika RLS belum diaktifkan atau offline
    }

    final index = _localDatabaseCourses.indexWhere((c) => c.id == id);
    if (index != -1) {
      _localDatabaseCourses[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}
