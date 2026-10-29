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
import 'package:flutter_ui_fundamentals/screens/edit_course_page.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockCourseSupabaseService extends CourseSupabaseService {
  Course currentCourse;
  _MockCourseSupabaseService({required this.currentCourse});

  @override
  Future<List<Course>> getCourses() async => [currentCourse];

  @override
  Future<void> updateCourse(int id, Course course) async {
    currentCourse = course;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 14: UPDATE: Mengubah Data di Database (Supabase)', () {
    test('83. Signature updateCourse(int id, Course course) sesuai kontrak CourseDataSource', () {
      final service = CourseSupabaseService();
      expect(service.updateCourse, isA<Function>());
      expect(service, isA<CourseDataSource>());
    });

    test('83b & 84. UPDATE data melalui CourseSupabaseService -> CourseRepository -> CourseProvider dan refresh list', () async {
      final service = CourseSupabaseService();
      final repository = CourseRepository(service);
      final provider = CourseProvider(repository);

      await provider.loadCourses();
      expect(provider.courses.any((c) => c.id == 1), isTrue);

      const updatedCourse = Course(
        id: 1,
        code: 'IF101',
        title: 'Dasar Pemrograman (Revisi)',
        credits: 4,
        status: 'done',
      );

      await provider.updateCourse(1, updatedCourse);

      // 84 & 85. Verifikasi list ter-refresh dan perubahan terlihat
      final courseAfterUpdate = provider.courses.firstWhere((c) => c.id == 1);
      expect(courseAfterUpdate.title, 'Dasar Pemrograman (Revisi)');
      expect(courseAfterUpdate.credits, 4);
      expect(courseAfterUpdate.status, 'done');
    });

    testWidgets('81. Tombol Edit pada CourseDetailPage membuka form Edit Course', (tester) async {
      const testCourse = Course(
        id: 2,
        code: 'IF102',
        title: 'Pemograman Berbasis Mobile',
        credits: 4,
        status: 'planned',
      );

      final service = _MockCourseSupabaseService(currentCourse: testCourse);
      final provider = CourseProvider(CourseRepository(service));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseDetailPage(course: testCourse),
          ),
        ),
      );

      // 81. Tombol Edit pada Course Detail
      final editButton = find.byTooltip('Edit Course');
      expect(editButton, findsOneWidget);
    });

    testWidgets('82 & 84. EditCoursePage mengubah title/credits/status dan me-refresh list', (tester) async {
      const testCourse = Course(
        id: 2,
        code: 'IF102',
        title: 'Pemograman Berbasis Mobile',
        credits: 4,
        status: 'planned',
      );

      final service = _MockCourseSupabaseService(currentCourse: testCourse);
      final provider = CourseProvider(CourseRepository(service));
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const EditCoursePage(course: testCourse),
          ),
        ),
      );

      expect(find.text('Edit Course'), findsOneWidget);

      // 82. Ubah title dan credits
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Course'),
        'Pemrograman Berbasis Mobile Modern',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'),
        '3',
      );

      // Submit form
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();

      // 84 & 85. Verifikasi SnackBar dan data di provider ter-update
      expect(find.text('Course berhasil diperbarui!'), findsOneWidget);
      expect(provider.courses.first.title, 'Pemrograman Berbasis Mobile Modern');
      expect(provider.courses.first.credits, 3);
    });

    test('Identitas Mahasiswa tetap tampil dan tidak berubah', () {
      expect(studentName, 'I Ketut Srijaya Sudarma');
      expect(studentId, '2415051063');
      expect(studentClass, 'PTI 5A');
    });
  });
}
