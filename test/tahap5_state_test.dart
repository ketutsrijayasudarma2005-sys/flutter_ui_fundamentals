//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/courses_page.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/widgets/error_view.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _TestRepository extends CourseRepository {
  List<Course> testCourses;
  bool shouldThrow;
  String errorMessage;

  _TestRepository({
    this.testCourses = const [],
    this.shouldThrow = false,
    this.errorMessage = 'Gagal mengambil course',
  }) : super(CourseApiService('https://dummy.api'));

  @override
  Future<List<Course>> getCourses({bool simulateError = false}) async {
    if (shouldThrow || simulateError) {
      throw Exception(errorMessage);
    }
    return testCourses;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 5: Loading, Success, Empty, dan Error State', () {
    // 30. Widget ErrorView (pesan + tombol Retry) di lib/widgets/error_view.dart
    testWidgets('30. Widget ErrorView menampilkan pesan error dan memicu callback onRetry', (tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Koneksi internet bermasalah',
              onRetry: () {
                retryTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Terjadi kesalahan:'), findsOneWidget);
      expect(find.text('Koneksi internet bermasalah'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retryTriggered, isTrue);
    });

    // 29a. Loading State
    testWidgets('29a. Loading State menampilkan CircularProgressIndicator', (tester) async {
      final repo = _TestRepository();
      final provider = CourseProvider(repo);
      provider.isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: CoursesPage(onCourseTap: (_) {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // 29b. Empty State
    testWidgets('29b. Empty State menampilkan pesan data course belum tersedia', (tester) async {
      final repo = _TestRepository(testCourses: []);
      final provider = CourseProvider(repo);
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: CoursesPage(onCourseTap: (_) {}),
          ),
        ),
      );

      expect(find.text('Data course belum tersedia'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });

    // 32. Simulasikan endpoint salah dan verifikasi Error UI
    testWidgets('32. Error State menampilkan ErrorView saat terjadi kegagalan endpoint', (tester) async {
      final repo = _TestRepository(
        shouldThrow: true,
        errorMessage: 'Exception: HTTP 404 Endpoint Tidak Ditemukan',
      );
      final provider = CourseProvider(repo);
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: CoursesPage(onCourseTap: (_) {}),
          ),
        ),
      );

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.textContaining('HTTP 404 Endpoint Tidak Ditemukan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    // 33. Kembalikan endpoint yang benar lalu refresh (Success State)
    testWidgets('33. Refresh mengembalikan data dan UI bertransisi ke Success State', (tester) async {
      final repo = _TestRepository(
        shouldThrow: true,
        errorMessage: 'Koneksi terputus',
        testCourses: [
          const Course(
            id: 1,
            code: 'MOB01',
            title: 'Flutter UI Fundamentals',
            credits: 3,
            status: 'active',
          ),
        ],
      );
      final provider = CourseProvider(repo);
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: CoursesPage(onCourseTap: (_) {}),
          ),
        ),
      );

      // Verifikasi awal: Error state
      expect(find.byType(ErrorView), findsOneWidget);

      // Perbaiki endpoint / kembalikan status sukses
      repo.shouldThrow = false;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verifikasi transisi ke Success state
      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Flutter UI Fundamentals'), findsOneWidget);
      expect(find.text('MOB01'), findsOneWidget);
    });

    // 31. Panggil loadCourses() satu kali saat provider dibuat
    test('31. Provider memiliki field courses, isLoading, error sesuai kontrak arsitektur', () {
      final provider = CourseProvider();
      expect(provider.courses, isA<List<Course>>());
      expect(provider.isLoading, isA<bool>());
      expect(provider.error, isNull);
      expect(provider.isEmpty, isTrue);
    });
  });
}
