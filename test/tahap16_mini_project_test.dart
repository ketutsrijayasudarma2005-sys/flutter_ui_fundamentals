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
import 'package:flutter_ui_fundamentals/screens/course_form_page.dart';
import 'package:flutter_ui_fundamentals/screens/course_list_page.dart';
import 'package:flutter_ui_fundamentals/screens/favorites_page.dart';
import 'package:flutter_ui_fundamentals/screens/responsive_shell.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:flutter_ui_fundamentals/widgets/error_view.dart';
import 'package:provider/provider.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockMemoryDataSource implements CourseDataSource {
  final List<Course> _items;
  bool shouldThrow = false;

  _MockMemoryDataSource([List<Course>? initial])
      : _items = List<Course>.from(initial ?? [
          const Course(
            id: 1,
            code: 'MOB01',
            title: 'Git & GitHub',
            credits: 2,
            status: 'active',
          ),
          const Course(
            id: 2,
            code: 'MOB02',
            title: 'Dart Fundamentals',
            credits: 2,
            status: 'planned',
          ),
          const Course(
            id: 3,
            code: 'MOB03',
            title: 'Flutter UI',
            credits: 3,
            status: 'planned',
          ),
        ]);

  @override
  Future<List<Course>> getCourses() async {
    if (shouldThrow) {
      throw Exception('Simulasi koneksi database gagal');
    }
    return List<Course>.from(_items);
  }

  @override
  Future<Course> createCourse(Course course) async {
    if (shouldThrow) {
      throw Exception('Simulasi insert gagal');
    }
    final newId = (_items.map((c) => c.id ?? 0).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
    final created = Course(
      id: newId,
      code: course.code,
      title: course.title,
      credits: course.credits,
      status: course.status,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    if (shouldThrow) {
      throw Exception('Simulasi update gagal');
    }
    final index = _items.indexWhere((c) => c.id == id);
    if (index != -1) {
      _items[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    if (shouldThrow) {
      throw Exception('Simulasi delete gagal');
    }
    _items.removeWhere((c) => c.id == id);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 16: Mini Project Integrasi: Course Data Manager', () {
    test('90, 91, 92, 93. Pemisahan arsitektur dan kontrak CourseDataSource', () {
      final CourseDataSource supabaseSource = CourseSupabaseService();
      final CourseDataSource apiSource = CourseApiService();
      expect(supabaseSource, isA<CourseDataSource>());
      expect(apiSource, isA<CourseDataSource>());

      // Repository dapat memakai salah satu data source secara independen
      final repoSupabase = CourseRepository(supabaseSource);
      final repoApi = CourseRepository(apiSource);

      expect(repoSupabase.dataSource, isA<CourseSupabaseService>());
      expect(repoApi.dataSource, isA<CourseApiService>());

      // Provider berkomunikasi hanya dengan repository
      final provider = CourseProvider(repoSupabase);
      expect(provider.repository, same(repoSupabase));
    });

    test('94. Uji CRUD (Create, Read, Update, Delete) via Provider & Repository', () async {
      final memorySource = _MockMemoryDataSource();
      final repository = CourseRepository(memorySource);
      final provider = CourseProvider(repository);

      // 1. READ
      await provider.loadCourses();
      expect(provider.courses.length, 3);
      expect(provider.courses[0].title, 'Git & GitHub');

      // 2. CREATE
      final newCourse = await provider.createCourse(
        const Course(
          code: 'MOB04',
          title: 'REST API',
          credits: 3,
          status: 'planned',
        ),
      );
      expect(newCourse.id, isNotNull);
      expect(provider.courses.length, 4);
      expect(provider.courses.any((c) => c.code == 'MOB04'), isTrue);

      // 3. UPDATE
      final createdId = newCourse.id!;
      await provider.updateCourse(
        createdId,
        Course(
          id: createdId,
          code: 'MOB04',
          title: 'REST API & Supabase Integration',
          credits: 4,
          status: 'active',
        ),
      );
      final updated = provider.courses.firstWhere((c) => c.id == createdId);
      expect(updated.title, 'REST API & Supabase Integration');
      expect(updated.credits, 4);
      expect(updated.status, 'active');

      // 4. DELETE
      await provider.deleteCourse(createdId, code: 'MOB04');
      expect(provider.courses.length, 3);
      expect(provider.courses.any((c) => c.id == createdId), isFalse);
    });

    test('95. Uji error state, retry, dan pemulihan', () async {
      final memorySource = _MockMemoryDataSource();
      final repository = CourseRepository(memorySource);
      final provider = CourseProvider(repository);

      // Sengaja gagal
      memorySource.shouldThrow = true;
      await provider.loadCourses();
      expect(provider.hasError, isTrue);
      expect(provider.error, contains('Simulasi koneksi database gagal'));

      // Pemulihan (kembalikan koneksi yang benar lalu retry)
      memorySource.shouldThrow = false;
      await provider.loadCourses();
      expect(provider.hasError, isFalse);
      expect(provider.error, isNull);
      expect(provider.courses.isNotEmpty, isTrue);
    });

    testWidgets('Tampilan CourseListPage memuat elemen desain screenshot dan aksi CRUD', (tester) async {
      final memorySource = _MockMemoryDataSource();
      final provider = CourseProvider(CourseRepository(memorySource));
      await provider.loadCourses();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseListPage(),
          ),
        ),
      );

      // Verifikasi AppBar
      expect(find.text('Course Data Manager'), findsOneWidget);

      // Verifikasi Identitas Mahasiswa
      expect(find.text('$studentId • $studentName'), findsOneWidget);

      // Verifikasi Tombol + Tambah Course
      expect(find.text('+ Tambah Course'), findsOneWidget);

      // Verifikasi Course cards
      expect(find.text('Git & GitHub'), findsOneWidget);
      expect(find.text('MOB01 • 2 SKS'), findsOneWidget);
      expect(find.text('Dart Fundamentals'), findsOneWidget);
      expect(find.text('Flutter UI'), findsOneWidget);

      // Verifikasi Tombol Edit & Delete
      expect(find.byTooltip('Edit Course'), findsNWidgets(3));
      expect(find.byTooltip('Hapus Course'), findsNWidgets(3));

      // Verifikasi Dialog Konfirmasi Delete
      await tester.tap(find.byTooltip('Hapus Course').first);
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Batalkan
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(provider.courses.length, 3);
    });

    testWidgets('CourseFormPage mendukung mode Tambah dan Edit dengan validasi', (tester) async {
      final memorySource = _MockMemoryDataSource();
      final provider = CourseProvider(CourseRepository(memorySource));
      await provider.loadCourses();

      // Test Mode Tambah
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const CourseFormPage(),
          ),
        ),
      );

      expect(find.text('Tambah Course'), findsWidgets);
      expect(find.text('Simpan Course'), findsOneWidget);

      // Submit tanpa input harus memicu validasi
      await tester.tap(find.text('Simpan Course'));
      await tester.pumpAndSettle();

      expect(find.text('Kode course wajib diisi'), findsOneWidget);
      expect(find.text('Judul course wajib diisi'), findsOneWidget);
      expect(find.text('Credits wajib diisi'), findsOneWidget);
    });

    testWidgets('ResponsiveShell beradaptasi responsif dan mempertahankan navigasi', (tester) async {
      final memorySource = _MockMemoryDataSource();
      final provider = CourseProvider(CourseRepository(memorySource));
      await provider.loadCourses();

      // Mobile screen (< 840px)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const ResponsiveShell(),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Layar lebar (>= 840px)
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CourseProvider>.value(
            value: provider,
            child: const ResponsiveShell(),
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
    });

    test('Favorites konsisten menggunakan code sebagai kunci', () async {
      final memorySource = _MockMemoryDataSource();
      final provider = CourseProvider(CourseRepository(memorySource));
      await provider.loadCourses();

      expect(provider.isFavorite('MOB01'), isFalse);
      provider.toggleFavorite('MOB01');
      expect(provider.isFavorite('MOB01'), isTrue);

      // Refresh data dari database tidak menghilangkan favorite
      await provider.loadCourses();
      expect(provider.isFavorite('MOB01'), isTrue);

      // Jika course dihapus, favorites dibersihkan otomatis
      await provider.deleteCourse(1, code: 'MOB01');
      expect(provider.isFavorite('MOB01'), isFalse);
    });

    test('Identitas Mahasiswa tetap tampil dan tidak berubah', () {
      expect(studentName, 'I Ketut Srijaya Sudarma');
      expect(studentId, '2415051063');
      expect(studentClass, 'PTI 5A');
    });
  });
}

