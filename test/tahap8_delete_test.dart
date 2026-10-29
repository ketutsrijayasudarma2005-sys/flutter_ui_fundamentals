//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/course_detail_page.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockCourseApiService extends CourseApiService {
  List<Course> currentCourses;
  bool shouldThrow;

  _MockCourseApiService({
    required this.currentCourses,
    this.shouldThrow = false,
  }) : super('https://mock.api');

  @override
  Future<List<Course>> getCourses() async {
    return currentCourses;
  }

  @override
  Future<void> deleteCourse(int id) async {
    if (shouldThrow) {
      throw Exception('Gagal menghapus course dari Mock Service');
    }
    currentCourses.removeWhere((c) => c.id == id);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 8: HTTP DELETE: Menghapus Resource', () {
    test('CourseApiService memiliki fungsi deleteCourse(int id)', () {
      final service = CourseApiService();
      expect(service.deleteCourse, isA<Function>());
    });

    test('48, 49, 51. CourseProvider deleteCourse menghapus resource, me-refresh data, dan membersihkan favorites', () async {
      const course1 = Course(id: 1, code: 'MOB01', title: 'Git & GitHub', credits: 2, status: 'done');
      const course2 = Course(id: 2, code: 'MOB02', title: 'Dart Fundamentals', credits: 2, status: 'done');
      final mockService = _MockCourseApiService(currentCourses: [course1, course2]);
      final repository = CourseRepository(mockService);
      final provider = CourseProvider(repository);
      await provider.loadCourses();

      // Tambahkan MOB01 ke favorites
      provider.toggleFavorite('MOB01');
      expect(provider.isFavorite('MOB01'), isTrue);

      // Jalankan deleteCourse
      await provider.deleteCourse(1, code: 'MOB01');

      // 49. Refresh list
      expect(provider.courses.any((c) => c.id == 1), isFalse);
      expect(provider.courses.length, 1);

      // 51. Hapus juga dari favorites agar tidak tersisa data yatim
      expect(provider.isFavorite('MOB01'), isFalse);
    });

    // 46 & 47. Tombol Delete dan AlertDialog Konfirmasi
    testWidgets('46 & 47. Menampilkan tombol Hapus dan menampilkan AlertDialog konfirmasi sebelum menghapus', (tester) async {
      const testCourse = Course(
        id: 1,
        code: 'MOB01',
        title: 'Git & GitHub',
        credits: 2,
        status: 'done',
      );
      final mockService = _MockCourseApiService(currentCourses: [testCourse]);
      final provider = CourseProvider(CourseRepository(mockService));
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseDetailPage(course: testCourse),
          ),
        ),
      );

      // 46. Tombol Delete tersedia
      expect(find.text('Hapus Course'), findsOneWidget);
      expect(find.byTooltip('Hapus Course'), findsOneWidget);

      // Klik tombol Hapus Course
      await tester.tap(find.text('Hapus Course'));
      await tester.pumpAndSettle();

      // 47. AlertDialog konfirmasi muncul
      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin menghapus course "Git & GitHub" (MOB01)?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Klik Batal -> Dialog tertutup tanpa menghapus
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Hapus'), findsNothing);
      expect(provider.courses.isNotEmpty, isTrue);
    });

    // 48, 49, 50, 51. Konfirmasi Hapus -> Jalankan DELETE -> SnackBar -> Bersihkan Favorites
    testWidgets('48, 49, 50, 51. Menyetujui dialog menjalankan DELETE, menampilkan SnackBar, dan membersihkan favorites', (tester) async {
      const testCourse = Course(
        id: 1,
        code: 'MOB01',
        title: 'Git & GitHub',
        credits: 2,
        status: 'done',
      );
      final mockService = _MockCourseApiService(currentCourses: [testCourse]);
      final provider = CourseProvider(CourseRepository(mockService));
      await provider.loadCourses();

      // Tambahkan ke favorites
      provider.toggleFavorite('MOB01');
      expect(provider.isFavorite('MOB01'), isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseDetailPage(course: testCourse),
          ),
        ),
      );

      // Buka dialog konfirmasi
      await tester.tap(find.text('Hapus Course'));
      await tester.pumpAndSettle();

      // 48. Setujui konfirmasi
      await tester.tap(find.text('Hapus'));
      await tester.pump();

      // 49 & 50. SnackBar berhasil muncul
      expect(find.text('Course berhasil dihapus!'), findsOneWidget);

      // 49. Data ter-refresh dan terhapus
      expect(provider.courses.isEmpty, isTrue);

      // 51. Favorites bersih
      expect(provider.isFavorite('MOB01'), isFalse);
    });

    // Skenario Error saat DELETE gagal
    testWidgets('50. Menampilkan SnackBar error jika DELETE gagal', (tester) async {
      const testCourse = Course(
        id: 1,
        code: 'MOB01',
        title: 'Git & GitHub',
        credits: 2,
        status: 'done',
      );
      final mockService = _MockCourseApiService(currentCourses: [testCourse], shouldThrow: true);
      final provider = CourseProvider(CourseRepository(mockService));
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseDetailPage(course: testCourse),
          ),
        ),
      );

      await tester.tap(find.text('Hapus Course'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pump();

      expect(find.textContaining('Gagal menghapus course:'), findsOneWidget);
    });
  });
}

