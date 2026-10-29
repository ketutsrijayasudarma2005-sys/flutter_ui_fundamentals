//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/config/supabase_config.dart';
import 'package:flutter_ui_fundamentals/constants.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 12: SELECT: Membaca Data dari Database (Supabase)', () {
    test('71. CourseSupabaseService mengimplementasikan CourseDataSource', () {
      final service = CourseSupabaseService();
      expect(service, isA<CourseDataSource>());
    });

    test('71b. CourseSupabaseService mengimplementasikan seluruh kontrak CourseDataSource', () {
      final service = CourseSupabaseService();
      expect(service.getCourses, isA<Function>());
      expect(service.createCourse, isA<Function>());
      expect(service.updateCourse, isA<Function>());
      expect(service.deleteCourse, isA<Function>());
    });

    test('72 & 73. Mapping response dari Supabase ke List<Course>', () {
      final mockData = [
        {
          'id': 1,
          'code': 'MOB01',
          'title': 'Git & GitHub',
          'credits': 2,
          'status': 'done',
          'category': 'Version Control',
        },
        {
          'id': 2,
          'code': 'MOB02',
          'title': 'Dart Fundamentals',
          'credits': 2,
          'status': 'done',
          'category': 'Programming',
        },
        {
          'id': 3,
          'code': 'MOB03',
          'title': 'Flutter UI Fundamentals',
          'credits': 3,
          'status': 'active',
          'category': 'Flutter',
        },
      ];

      final courseList = mockData.map((e) => Course.fromJson(e)).toList();

      expect(courseList.length, 3);
      expect(courseList[0].id, 1);
      expect(courseList[0].code, 'MOB01');
      expect(courseList[0].title, 'Git & GitHub');
      expect(courseList[0].credits, 2);
      expect(courseList[0].status, 'done');
      expect(courseList[1].code, 'MOB02');
      expect(courseList[2].code, 'MOB03');
    });

    test('74. Integrasi CourseSupabaseService dengan CourseRepository dan CourseProvider', () async {
      // Data source tiruan berbasis implementasi CourseSupabaseService
      final service = CourseSupabaseService();
      final repository = CourseRepository(service);
      expect(repository.dataSource, same(service));

      final provider = CourseProvider(repository);
      expect(provider.repository, same(repository));
    });

    test('75. Identitas Mahasiswa tetap tampil dan tidak berubah', () {
      expect(studentName, 'I Ketut Srijaya Sudarma');
      expect(studentId, '2415051063');
      expect(studentClass, 'PTI 5A');
    });
    test('72b. Real Supabase client connectivity test', () async {
      // Test URL construction and query
      final client = SupabaseClient(SupabaseConfig.normalizedUrl, SupabaseConfig.supabaseAnonKey);
      final service = CourseSupabaseService(client);
      final data = await service.getCourses();
      expect(data, isA<List<Course>>());
    });
  });
}
