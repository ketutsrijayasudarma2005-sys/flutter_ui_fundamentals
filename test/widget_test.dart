import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/course_state.dart';
import 'package:flutter_ui_fundamentals/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Course Explorer HomePage and interaction test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CourseState>(
        create: (_) => CourseState(),
        child: const MyApp(),
      ),
    );

    // Verifikasi elemen halaman Home sesuai desain
    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.text('Course Explorer'), findsWidgets);
    expect(find.text('Identitas Mahasiswa'), findsOneWidget);
    expect(find.text('Nama: $studentName'), findsOneWidget);
    expect(find.text('NIM: $studentId'), findsOneWidget);
    expect(find.text('Tampilkan Info'), findsOneWidget);

    // Klik tombol Tampilkan Info
    await tester.tap(find.text('Tampilkan Info'));
    await tester.pumpAndSettle();

    // Verifikasi dialog informasi muncul
    expect(find.text('Informasi'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    // Tutup dialog
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    // Berpindah ke tab Courses
    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();

    // Verifikasi daftar courses dan toggle favorit
    final favoriteButtons = find.byTooltip('Tambah ke favorit');
    expect(favoriteButtons, findsWidgets);

    await tester.tap(favoriteButtons.first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);
  });
}


