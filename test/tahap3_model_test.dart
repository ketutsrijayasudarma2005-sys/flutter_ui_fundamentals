import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/main.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 3: Model Dart: Course.fromJson() dan toJson()', () {
    // 18. Perbarui lib/models/course.dart: pertahankan code, title, credits, status; tambah id & toJson()
    test('18. Model Course memiliki id nullable, field utama, dan method toJson()', () {
      const course = Course(
        id: 42,
        code: 'TEST01',
        title: 'Pengujian Model',
        credits: 3,
        status: 'active',
      );

      expect(course.id, 42);
      expect(course.code, 'TEST01');
      expect(course.title, 'Pengujian Model');
      expect(course.credits, 3);
      expect(course.status, 'active');

      final json = course.toJson();
      expect(json['id'], 42);
      expect(json['code'], 'TEST01');
      expect(json['title'], 'Pengujian Model');
      expect(json['credits'], 3);
      expect(json['status'], 'active');
    });

    // 19. Jika API latihan tidak mengirim status, fromJson memberi nilai default 'planned'
    test('19. fromJson memberikan nilai default "planned" jika status null atau tidak ada', () {
      final jsonTanpaStatus = {
        'id': 10,
        'code': 'IF100',
        'title': 'Struktur Data',
        'credits': 4,
      };

      final course = Course.fromJson(jsonTanpaStatus);
      expect(course.status, 'planned');
    });

    // 20. Sesuaikan nama field dengan JSON API yang digunakan
    test('20. fromJson memetakan seluruh field sesuai respons JSON REST API', () {
      final jsonApi = {
        'id': 4,
        'code': 'MOB04',
        'title': 'State Management Provider',
        'credits': 2,
        'status': 'planned',
        'created_at': '2026-10-21T03:28:09.576271Z',
      };

      final course = Course.fromJson(jsonApi);
      expect(course.id, 4);
      expect(course.code, 'MOB04');
      expect(course.title, 'State Management Provider');
      expect(course.credits, 2);
      expect(course.status, 'planned');
      expect(course.createdAt, '2026-10-21T03:28:09.576271Z');
    });

    // 21. Konversi response list menjadi List<Course>
    test('21. fetchCourses berhasil mengonversi response list menjadi List<Course>', () async {
      final courses = await fetchCourses();
      expect(courses, isA<List<Course>>());
      expect(courses.length, greaterThanOrEqualTo(3));

      // Verifikasi bahwa setiap item di dalam list benar-benar bertipe Course
      for (final course in courses) {
        expect(course, isA<Course>());
        expect(course.code.isNotEmpty, isTrue);
        expect(course.title.isNotEmpty, isTrue);
        expect(course.credits, greaterThan(0));
        expect(course.status.isNotEmpty, isTrue);
      }
    });

    // 22. Tampilkan code, title, dan status minimal tiga course pada UI
    test('22. Memastikan minimal 3 course memiliki data code, title, dan status lengkap', () async {
      final courses = await fetchCourses();
      expect(courses.length, greaterThanOrEqualTo(3));

      final firstThree = courses.take(3).toList();
      for (var i = 0; i < firstThree.length; i++) {
        final c = firstThree[i];
        expect(c.code, isNotEmpty);
        expect(c.title, isNotEmpty);
        expect(c.status, isNotEmpty);
        // ignore: avoid_print
        print('Course ${i + 1}: [${c.code}] ${c.title} -> status: ${c.status}');
      }
    });
  });
}
