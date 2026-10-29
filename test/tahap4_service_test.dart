import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/constants.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 4: Memindahkan HTTP ke Service Layer', () {
    // 23. Buat lib/services/course_api_service.dart
    test('23a. CourseApiService dapat diinisialisasi dengan baseUrl dan mengarah ke endpoint yang benar', () {
      final service = CourseApiService(baseUrl);
      expect(service.baseUrl, baseUrl);
    });

    test('23b. CourseApiService.getCourses() berhasil mengambil data course dari REST API', () async {
      final service = CourseApiService(baseUrl);
      final courses = await service.getCourses();

      expect(courses, isA<List<Course>>());
      expect(courses.isNotEmpty, isTrue);
      expect(courses.length, greaterThanOrEqualTo(3));

      // Verifikasi item bertipe Course
      for (final course in courses) {
        expect(course.code, isNotEmpty);
        expect(course.title, isNotEmpty);
        expect(course.credits, greaterThan(0));
        expect(course.status, isNotEmpty);
      }
    });

    test('23c. CourseApiService.getCourses() melempar Exception jika endpoint salah (status bukan 200)', () async {
      final invalidService = CourseApiService('https://course-api-pearl.vercel.app/invalid_endpoint');
      expect(
        () async => await invalidService.getCourses(),
        throwsA(isA<Exception>()),
      );
    });

    // 24. Ubah dependency CourseRepository menjadi CourseApiService
    test('24. CourseRepository menerima CourseApiService dan getCourses memanggil service.getCourses()', () async {
      final service = CourseApiService(baseUrl);
      final repository = CourseRepository(service);

      expect(repository.service, isA<CourseApiService>());
      final courses = await repository.getCourses();
      expect(courses, isA<List<Course>>());
      expect(courses.isNotEmpty, isTrue);
    });

    // 25. lib/services/course_service.dart dihapus dengan git rm
    test('25. lib/services/course_service.dart sudah tidak ada dalam proyek', () {
      final oldServiceFile = File('lib/services/course_service.dart');
      expect(oldServiceFile.existsSync(), isFalse);
    });

    // 26 & 27. Screen hanya memanggil service/repository via Provider
    test('26 & 27. CourseProvider terintegrasi dengan CourseRepository dan CourseApiService', () async {
      final provider = CourseProvider();
      expect(provider.repository, isA<CourseRepository>());
      expect(provider.repository.service, isA<CourseApiService>());

      await provider.loadCourses();
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.courses.isNotEmpty, isTrue);
    });
  });
}
