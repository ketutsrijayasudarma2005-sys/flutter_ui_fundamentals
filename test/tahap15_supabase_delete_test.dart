//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/constants.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/course_detail_page.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockCourseSupabaseService extends CourseSupabaseService {
  List<Course> mockCourses;
  _MockCourseSupabaseService({required this.mockCourses});

  @override
  Future<List<Course>> getCourses() async => List<Course>.from(mockCourses);

  @override
  Future<void> deleteCourse(int id) async {
    mockCourses.removeWhere((c) => c.id == id);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 15: DELETE: Menghapus Data dari Database (Supabase)', () {
    test('87. Signature deleteCourse(int id) sesuai kontrak CourseDataSource', () {
      final service = CourseSupabaseService();
      expect(service.deleteCourse, isA<Function>());
      expect(service, isA<CourseDataSource>());
    });

    test('87b & 88. DELETE data melalui CourseSupabaseService -> CourseRepository -> CourseProvider dan refresh list', () async {
      final service = CourseSupabaseService();
      final repository = CourseRepository(service);
      final provider = CourseProvider(repository);

      await provider.loadCourses();
      expect(provider.courses.any((c) => c.id == 3), isTrue);
      final initialCount = provider.courses.length;

      // 87. DELETE berdasarkan id
      await provider.deleteCourse(3);

      // 88 & 89. Refresh list dan pastikan data hilang dari list aplikasi
      expect(provider.courses.length, initialCount - 1);
      expect(provider.courses.any((c) => c.id == 3), isFalse);
    });

    testWidgets('86, 87, 88, 89. Dialog konfirmasi sebelum DELETE dan refresh list pada UI', (tester) async {
      final initialCourses = [
        const Course(
          id: 1,
          code: 'IF101',
          title: 'Dasar Pemrograman',
          credits: 3,
          status: 'active',
        ),
        const Course(
          id: 2,
          code: 'IF102',
          title: 'Pemograman Berbasis Mobile',
          credits: 4,
          status: 'planned',
        ),
      ];

      final service = _MockCourseSupabaseService(mockCourses: initialCourses);
      final provider = CourseProvider(CourseRepository(service));
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseDetailPage(course: Course(
              id: 1,
              code: 'IF101',
              title: 'Dasar Pemrograman',
              credits: 3,
              status: 'active',
            )),
          ),
        ),
      );

      // 86. Klik tombol Hapus Course
      final deleteButton = find.byTooltip('Hapus Course');
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Verifikasi AlertDialog konfirmasi muncul
      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Konfirmasi penghapusan
      await tester.tap(find.text('Hapus'));
      await tester.pump();

      // 88 & 89. Verifikasi SnackBar berhasil dan data terhapus dari provider
      expect(find.text('Course berhasil dihapus!'), findsOneWidget);
      expect(provider.courses.any((c) => c.id == 1), isFalse);
      expect(provider.courses.length, 1);
    });

    test('Identitas Mahasiswa tetap tampil dan tidak berubah', () {
      expect(studentName, 'I Ketut Srijaya Sudarma');
      expect(studentId, '2415051063');
      expect(studentClass, 'PTI 5A');
    });
  });
}
