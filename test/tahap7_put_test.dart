//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/course_detail_page.dart';
import 'package:flutter_ui_fundamentals/screens/edit_course_page.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockCourseApiService extends CourseApiService {
  Course currentCourse;
  bool shouldThrow;

  _MockCourseApiService({
    required this.currentCourse,
    this.shouldThrow = false,
  }) : super('https://mock.api');

  @override
  Future<List<Course>> getCourses() async {
    return [currentCourse];
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    if (shouldThrow) {
      throw Exception('Gagal memperbarui course dari Mock Service');
    }
    currentCourse = course;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 7: HTTP PUT/PATCH: Memperbarui Resource', () {
    test('43a. CourseApiService memiliki fungsi updateCourse(int id, Course course)', () {
      final service = CourseApiService();
      expect(service.updateCourse, isA<Function>());
    });

    test('43b. CourseRepository dan CourseProvider mengintegrasikan updateCourse dan refresh data', () async {
      const initialCourse = Course(
        id: 5,
        code: 'MOB05',
        title: 'REST API & Database',
        credits: 3,
        status: 'active',
      );
      final mockService = _MockCourseApiService(currentCourse: initialCourse);
      final repository = CourseRepository(mockService);
      final provider = CourseProvider(repository);

      expect(provider.isSaving, isFalse);

      const updatedCourse = Course(
        id: 5,
        code: 'MOB05',
        title: 'REST API, GraphQL & Database',
        credits: 4,
        status: 'done',
      );

      await provider.updateCourse(5, updatedCourse);
      expect(provider.isSaving, isFalse);

      // 45. Refresh data setelah update
      expect(provider.courses.first.title, 'REST API, GraphQL & Database');
      expect(provider.courses.first.credits, 4);
      expect(provider.courses.first.status, 'done');
    });

    // 41. Tombol Edit pada Course Detail
    testWidgets('41. CourseDetailPage menampilkan tombol Edit Course', (tester) async {
      const testCourse = Course(
        id: 1,
        code: 'MOB01',
        title: 'Git & GitHub',
        credits: 2,
        status: 'done',
      );
      final mockService = _MockCourseApiService(currentCourse: testCourse);
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseDetailPage(course: testCourse),
          ),
        ),
      );

      expect(find.text('Edit Course'), findsOneWidget);
      expect(find.byTooltip('Edit Course'), findsOneWidget);
    });

    // 42. Form edit diisi data lama dan field code dibuat read-only
    testWidgets('42. EditCoursePage mengisi form dengan data lama dan field code bersifat read-only', (tester) async {
      const testCourse = Course(
        id: 3,
        code: 'MOB03',
        title: 'Flutter UI Fundamentals',
        credits: 3,
        status: 'active',
      );
      final mockService = _MockCourseApiService(currentCourse: testCourse);
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const EditCoursePage(course: testCourse),
          ),
        ),
      );

      expect(find.text('Edit Course'), findsOneWidget);

      // Verifikasi data lama terisi pada controller
      final codeFinder = find.widgetWithText(TextFormField, 'Kode Course (Read-only)');
      expect(codeFinder, findsOneWidget);
      final textField = tester.widget<TextField>(
        find.descendant(of: codeFinder, matching: find.byType(TextField)),
      );
      expect(textField.controller?.text, 'MOB03');
      expect(textField.readOnly, isTrue);

      final titleFinder = find.widgetWithText(TextFormField, 'Judul Course');
      final titleField = tester.widget<TextFormField>(titleFinder);
      expect(titleField.controller?.text, 'Flutter UI Fundamentals');

      final creditsFinder = find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)');
      final creditsField = tester.widget<TextFormField>(creditsFinder);
      expect(creditsField.controller?.text, '3');
    });

    // 43, 44, 45. Submit form, guard submit ganda, context.mounted, SnackBar, dan refresh
    testWidgets('43, 44, 45. Berhasil menyimpan perubahan, menampilkan SnackBar, dan memperbarui provider', (tester) async {
      const initialCourse = Course(
        id: 2,
        code: 'MOB02',
        title: 'Dart Fundamentals',
        credits: 2,
        status: 'done',
      );
      final mockService = _MockCourseApiService(currentCourse: initialCourse);
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const EditCoursePage(course: initialCourse),
          ),
        ),
      );

      // Ubah judul dan SKS
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Course'),
        'Dart & Modern Flutter',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'),
        '3',
      );

      // Submit form
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();

      // 45. Tampilkan hasil SnackBar berhasil
      expect(find.text('Course berhasil diperbarui!'), findsOneWidget);

      // Verifikasi provider telah ter-refresh dengan data baru
      expect(provider.courses.first.title, 'Dart & Modern Flutter');
      expect(provider.courses.first.credits, 3);
    });

    // 44. Menampilkan SnackBar error jika update gagal
    testWidgets('44. Menampilkan SnackBar error jika update PUT gagal', (tester) async {
      const initialCourse = Course(
        id: 4,
        code: 'MOB04',
        title: 'State Management',
        credits: 2,
        status: 'planned',
      );
      final mockService = _MockCourseApiService(
        currentCourse: initialCourse,
        shouldThrow: true,
      );
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const EditCoursePage(course: initialCourse),
          ),
        ),
      );

      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();

      expect(find.textContaining('Gagal memperbarui course:'), findsOneWidget);
    });
  });
}
