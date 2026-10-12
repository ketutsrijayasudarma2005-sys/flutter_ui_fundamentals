import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/main.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/screens/courses_page.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Course Explorer HomePage and interaction test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CourseProvider>(
        create: (_) => CourseProvider(),
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
    await tester.tap(find.text('Courses').last);
    await tester.pumpAndSettle();

    // 55. Verifikasi icon favorite pada CourseCard
    final addFavoriteButtons = find.byTooltip('Tambah ke favorit');
    expect(addFavoriteButtons, findsWidgets);

    // Toggle dari list
    await tester.tap(addFavoriteButtons.first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);

    // Buka Course Detail Page dari item pertama
    await tester.tap(find.text('Git & GitHub'));
    await tester.pumpAndSettle();

    // 56. Tampilkan status favorite pada DetailPage
    expect(find.text('Course Detail'), findsOneWidget);
    expect(find.text('Status Favorit: '), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Hapus dari Favorites'), findsOneWidget);

    // Kembali ke halaman utama
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Buka FavoritesPage lewat icon AppBar
    await tester.tap(find.byTooltip('Favorites').first);
    await tester.pumpAndSettle();

    // 57. Buat FavoritesPage yang hanya menampilkan course favorite
    expect(find.text('Courses Favorit'), findsOneWidget);
    expect(find.text('Git & GitHub'), findsOneWidget);

    // 58. Toggle favorit dari FavoritesPage dan pastikan screen lain konsisten
    final removeFavoriteInFavorites = find.byTooltip('Hapus dari favorit');
    expect(removeFavoriteInFavorites, findsOneWidget);
    await tester.tap(removeFavoriteInFavorites);
    await tester.pumpAndSettle();

    // Setelah di-remove, daftar favorit kosong
    expect(find.text('Belum ada course favorit.'), findsOneWidget);

    // Kembali ke Courses tab
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Di Courses tab, item sudah kembali menjadi bukan favorit
    expect(find.byTooltip('Hapus dari favorit'), findsNothing);

    // 67. Kasus C: Verifikasi error state pada CoursesPage
    final provider = tester.element(find.byType(CoursesPage)).read<CourseProvider>();
    await provider.loadCourses(simulateError: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Terjadi kesalahan:'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    // Pulihkan data dengan menekan Coba Lagi
    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Git & GitHub'), findsWidgets);

    // 68. Kasus D: Form Profile dengan async dan mounted check
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama'), 'Budi');
    await tester.enterText(find.widgetWithText(TextFormField, 'NIM'), '1234567890');
    await tester.enterText(find.widgetWithText(TextFormField, 'Komentar'), 'Sangat informatif!');
    await tester.tap(find.text('Kirim Feedback'));

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Feedback berhasil dikirim.'), findsOneWidget);
  });
}
