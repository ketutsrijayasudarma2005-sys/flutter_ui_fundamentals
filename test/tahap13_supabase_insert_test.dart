//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/constants.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/add_course_page.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 13: INSERT: Menambah Data ke Database (Supabase)', () {
    test('78a. CourseSupabaseService memiliki method createCourse(Course course) yang mengembalikan Future<Course>', () {
      final service = CourseSupabaseService();
      expect(service.createCourse, isA<Function>());
      expect(service, isA<CourseDataSource>());
    });

    test('78b & 79. INSERT data melalui CourseSupabaseService -> CourseRepository -> CourseProvider dan refresh list', () async {
      final service = CourseSupabaseService();
      final repository = CourseRepository(service);
      final provider = CourseProvider(repository);

      await provider.loadCourses();
      final initialCount = provider.courses.length;

      const newCourse = Course(
        code: 'IF104',
        title: 'Pemrograman Web Lanjut',
        credits: 3,
        status: 'planned',
      );

      final created = await provider.createCourse(newCourse);

      // 78. Method mengembalikan Course (row baru)
      expect(created, isA<Course>());
      expect(created.code, 'IF104');
      expect(created.title, 'Pemrograman Web Lanjut');
      expect(created.credits, 3);
      expect(created.status, 'planned');
      expect(created.id, isNotNull);

      // 79. List ter-refresh otomatis setelah berhasil
      expect(provider.courses.length, initialCount + 1);
      expect(provider.courses.any((c) => c.code == 'IF104'), isTrue);
    });

    testWidgets('76 & 77. Form Create Course (AddCoursePage) memvalidasi code, title, credits, dan status', (tester) async {
      final service = CourseSupabaseService();
      final provider = CourseProvider(CourseRepository(service));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const AddCoursePage(),
          ),
        ),
      );

      // Verifikasi komponen form
      expect(find.byType(AddCoursePage), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Kode Course'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Judul Course'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      // 77. Validasi jika field wajib kosong
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Course'));
      await tester.pump();

      expect(find.text('Kode course wajib diisi'), findsOneWidget);
      expect(find.text('Judul course wajib diisi'), findsOneWidget);
      expect(find.text('Credits wajib diisi'), findsOneWidget);

      // Validasi credits harus angka
      await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), 'tiga');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Course'));
      await tester.pump();

      expect(find.text('Credits harus berupa angka positif'), findsOneWidget);

      // 80. Isi form valid dan submit
      await tester.enterText(find.widgetWithText(TextFormField, 'Kode Course'), 'IF105');
      await tester.enterText(find.widgetWithText(TextFormField, 'Judul Course'), 'Kecerdasan Buatan');
      await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah SKS (Credits)'), '3');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Course'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(provider.courses.any((c) => c.code == 'IF105'), isTrue);
    });

    test('Identitas Mahasiswa tetap tampil dan tidak berubah', () {
      expect(studentName, 'I Ketut Srijaya Sudarma');
      expect(studentId, '2415051063');
      expect(studentClass, 'PTI 5A');
    });
  });
}
