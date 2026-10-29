//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/add_course_page.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockCourseApiService extends CourseApiService {
  Course? createdCourse;
  bool shouldThrow;

  _MockCourseApiService({this.shouldThrow = false})
      : super('https://mock.api');

  @override
  Future<List<Course>> getCourses() async {
    return [
      if (createdCourse != null) createdCourse!,
      const Course(
        id: 1,
        code: 'MOB01',
        title: 'Git & GitHub',
        credits: 2,
        status: 'done',
      ),
    ];
  }

  @override
  Future<Course> createCourse(Course course) async {
    if (shouldThrow) {
      throw Exception('Gagal membuat course dari Mock Service');
    }
    createdCourse = Course(
      id: 99,
      code: course.code,
      title: course.title,
      credits: course.credits,
      status: course.status,
    );
    return createdCourse!;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 6: HTTP POST: Membuat Resource Baru', () {
    test('36a. CourseApiService memiliki fungsi createCourse(Course course)', () {
      final service = CourseApiService();
      expect(service.createCourse, isA<Function>());
    });

    test('36b. CourseRepository dan CourseProvider mengintegrasikan createCourse', () async {
      final mockService = _MockCourseApiService();
      final repository = CourseRepository(mockService);
      final provider = CourseProvider(repository);

      expect(provider.isSaving, isFalse);

      const newCourse = Course(
        code: 'MOB06',
        title: 'Advanced State Management',
        credits: 3,
        status: 'planned',
      );

      final result = await provider.createCourse(newCourse);
      expect(result.code, 'MOB06');
      expect(result.title, 'Advanced State Management');
      expect(result.credits, 3);
      expect(result.id, 99);
      expect(provider.isSaving, isFalse);

      // 40. Refresh list setelah berhasil memanggil loadCourses()
      expect(provider.courses.any((c) => c.code == 'MOB06'), isTrue);
    });

    // 34 & 35. Form sederhana, field wajib, dan validasi credits berupa angka
    testWidgets('34 & 35. Form AddCoursePage menampilkan field code, title, credits, status dan memvalidasi input', (tester) async {
      final mockService = _MockCourseApiService();
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const AddCoursePage(),
          ),
        ),
      );

      expect(find.text('Tambah Course'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Kode Course'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Judul Course'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Simpan Course'), findsOneWidget);

      // Tekan tombol Simpan tanpa mengisi data -> Validasi gagal
      await tester.tap(find.text('Simpan Course'));
      await tester.pump();

      expect(find.text('Kode course wajib diisi'), findsOneWidget);
      expect(find.text('Judul course wajib diisi'), findsOneWidget);
      expect(find.text('Credits wajib diisi'), findsOneWidget);

      // Masukkan credits bukan angka
      await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), 'tiga');
      await tester.tap(find.text('Simpan Course'));
      await tester.pump();

      expect(find.text('Credits harus berupa angka positif'), findsOneWidget);
    });

    // 36, 37, 38, 39, 40. Kirim data via POST, nonaktifkan tombol saat saving, tampilkan SnackBar, dan refresh list
    testWidgets('37, 38, 39, 40. Berhasil mengirim form POST, menampilkan SnackBar, dan refresh provider', (tester) async {
      final mockService = _MockCourseApiService();
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const AddCoursePage(),
          ),
        ),
      );

      // Isi seluruh form secara valid
      await tester.enterText(find.widgetWithText(TextFormField, 'Kode Course'), 'MOB07');
      await tester.enterText(find.widgetWithText(TextFormField, 'Judul Course'), 'Clean Architecture');
      await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), '3');

      // Submit form
      await tester.tap(find.text('Simpan Course'));
      await tester.pump();

      // 38. SnackBar berhasil muncul
      expect(find.text('Course berhasil ditambahkan!'), findsOneWidget);

      // 40. Data di provider telah ter-refresh
      expect(provider.courses.any((c) => c.code == 'MOB07'), isTrue);
    });

    // 37 & 38. Skenario Error: SnackBar menampilkan pesan error saat POST gagal
    testWidgets('38. Menampilkan SnackBar error jika POST gagal', (tester) async {
      final mockService = _MockCourseApiService(shouldThrow: true);
      final provider = CourseProvider(CourseRepository(mockService));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const AddCoursePage(),
          ),
        ),
      );

      // Isi seluruh form secara valid
      await tester.enterText(find.widgetWithText(TextFormField, 'Kode Course'), 'MOB08');
      await tester.enterText(find.widgetWithText(TextFormField, 'Judul Course'), 'Error Course');
      await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), '2');

      // Submit form
      await tester.tap(find.text('Simpan Course'));
      await tester.pump();

      // 38. SnackBar gagal muncul
      expect(find.textContaining('Gagal menambahkan course:'), findsOneWidget);
    });
  });
}

