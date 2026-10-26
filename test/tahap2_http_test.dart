import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/main.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
  });

  group('Tahap 2: HTTP GET dari Flutter', () {
    // 13. Konstanta apiUrl sesuai endpoint latihan
    test('13. Konstanta apiUrl mengarah ke endpoint latihan yang benar', () {
      expect(apiUrl, 'https://course-api-pearl.vercel.app/courses');
    });

    // 14 & 15. Panggil GET melalui function asynchronous dan tampilkan jumlah item
    test('14 & 15. fetchCourses berhasil mengambil data dan menghasilkan jumlah item', () async {
      final items = await fetchCourses();
      expect(items, isA<List<dynamic>>());
      expect(items.isNotEmpty, isTrue);
      // ignore: avoid_print
      print('Status: 200 OK | Jumlah item: ${items.length}');
      expect(items.length, greaterThan(0));
    });

    // 16. Ubah sementara endpoint menjadi salah untuk melihat error
    test('16. Endpoint salah menghasilkan Exception status HTTP (misal: HTTP 404)', () async {
      const wrongUrl = 'https://course-api-pearl.vercel.app/courses_salah';
      expect(
        () async => await fetchCourses(wrongUrl),
        throwsA(isA<Exception>()),
      );
    });

    // 17. Kembalikan endpoint ke URL yang benar
    test('17. Kembalikan ke URL benar dan request kembali sukses', () async {
      final items = await fetchCourses(apiUrl);
      expect(items, isA<List<dynamic>>());
      expect(items.isNotEmpty, isTrue);
      // ignore: avoid_print
      print('URL valid dipulihkan | Jumlah item: ${items.length}');
    });
  });
}
