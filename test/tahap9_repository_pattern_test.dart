//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/constants.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';

class _RealHttpOverrides extends HttpOverrides {}

// Mock data source mengimplementasikan CourseDataSource
class _InMemoryCourseDataSource implements CourseDataSource {
  final List<Course> _items = [
    const Course(id: 1, code: 'MOB01', title: 'Git & GitHub', credits: 2, status: 'done'),
    const Course(id: 2, code: 'MOB02', title: 'Dart Fundamentals', credits: 2, status: 'done'),
    const Course(id: 3, code: 'MOB03', title: 'Flutter UI Fundamentals', credits: 3, status: 'active'),
  ];

  @override
  Future<List<Course>> getCourses() async => List<Course>.from(_items);

  @override
  Future<Course> createCourse(Course course) async {
    final newId = (_items.isNotEmpty ? _items.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b) : 0) + 1;
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
    final index = _items.indexWhere((c) => c.id == id);
    if (index != -1) {
      _items[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    _items.removeWhere((c) => c.id == id);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 9: Repository Pattern untuk REST API', () {
    // 52. CourseDataSource sebagai kontrak dan CourseApiService implements CourseDataSource
    test('52. CourseApiService implements CourseDataSource', () {
      final service = CourseApiService(apiBaseUrl);
      expect(service, isA<CourseDataSource>());
    });

    // 53. CourseRepository menerima CourseDataSource sebagai abstraksi
    test('53. CourseRepository menerima CourseDataSource abstrak', () {
      final CourseDataSource dataSource = _InMemoryCourseDataSource();
      final repository = CourseRepository(dataSource);

      expect(repository.dataSource, isA<CourseDataSource>());
      expect(repository.service, isA<CourseDataSource>());
    });

    // 54. CourseProvider hanya berkomunikasi dengan CourseRepository melalui constructor
    test('54. CourseProvider berkomunikasi dengan CourseRepository', () async {
      final CourseDataSource dataSource = _InMemoryCourseDataSource();
      final repository = CourseRepository(dataSource);
      final provider = CourseProvider(repository);

      expect(provider.repository, same(repository));

      await provider.loadCourses();
      expect(provider.courses.length, 3);
    });

    // 57. Uji seluruh GET / POST / UPDATE / DELETE melalui Repository Pattern
    test('57a. Uji GET melalui Repository Pattern', () async {
      final repository = CourseRepository(_InMemoryCourseDataSource());
      final provider = CourseProvider(repository);

      await provider.loadCourses();
      expect(provider.courses.length, 3);
      expect(provider.courses.first.code, 'MOB01');
    });

    test('57b. Uji POST (createCourse) melalui Repository Pattern', () async {
      final repository = CourseRepository(_InMemoryCourseDataSource());
      final provider = CourseProvider(repository);
      await provider.loadCourses();

      const newCourse = Course(
        code: 'MOB04',
        title: 'Navigation',
        credits: 2,
        status: 'planned',
      );

      final created = await provider.createCourse(newCourse);
      expect(created.code, 'MOB04');
      expect(created.id, 4);

      // Verifikasi list ter-refresh otomatis
      expect(provider.courses.length, 4);
      expect(provider.courses.any((c) => c.code == 'MOB04'), isTrue);
    });

    test('57c. Uji UPDATE (updateCourse) melalui Repository Pattern', () async {
      final repository = CourseRepository(_InMemoryCourseDataSource());
      final provider = CourseProvider(repository);
      await provider.loadCourses();

      const updatedCourse = Course(
        id: 3,
        code: 'MOB03',
        title: 'Flutter UI Fundamentals (Updated)',
        credits: 4,
        status: 'done',
      );

      await provider.updateCourse(3, updatedCourse);

      // Verifikasi data ter-update
      final item = provider.courses.firstWhere((c) => c.id == 3);
      expect(item.title, 'Flutter UI Fundamentals (Updated)');
      expect(item.credits, 4);
      expect(item.status, 'done');
    });

    test('57d. Uji DELETE (deleteCourse) melalui Repository Pattern', () async {
      final repository = CourseRepository(_InMemoryCourseDataSource());
      final provider = CourseProvider(repository);
      await provider.loadCourses();

      // Tambahkan ke favorites dulu
      provider.toggleFavorite('MOB01');
      expect(provider.isFavorite('MOB01'), isTrue);

      await provider.deleteCourse(1, code: 'MOB01');

      // Verifikasi terhapus dari list dan favorites
      expect(provider.courses.any((c) => c.id == 1), isFalse);
      expect(provider.courses.length, 2);
      expect(provider.isFavorite('MOB01'), isFalse);
    });
  });
}

