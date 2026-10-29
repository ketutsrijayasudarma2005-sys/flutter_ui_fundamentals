# flutter_ui_fundamentals

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:pp

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Tahap 1 — Membaca REST Endpoint dan JSON

**Endpoint URL:** https://course-api-pearl.vercel.app/courses

**HTTP Method:** GET

**Resource:** courses

**Status Code:** Belum dicatat; perlu dikonfirmasi melalui Postman.

**Format Respons:** JSON array.

**Field JSON:**
1. `id`: identitas course.
2. `code`: kode course.
3. `title`: judul course.
4. `credits`: jumlah kredit.
5. `status`: status course.
6. `created_at`: waktu pembuatan data.

**Catatan/Temuan:**

Endpoint `/courses` digunakan untuk mengambil daftar data course menggunakan metode GET. Respons yang diterima berbentuk JSON array yang berisi objek course. Setiap objek memiliki informasi seperti identitas, kode, judul, jumlah kredit, status, dan waktu pembuatan. Struktur data ini menjadi dasar untuk memahami respons REST API sebelum dilakukan integrasi dengan aplikasi Flutter.

---

## Tahap 2 — HTTP GET dari Flutter

### 13. Konstanta `apiUrl`
Konstanta `apiUrl` didefinisikan pada [lib/constants.dart](file:///c:/src/flutter_ui_fundamentals/lib/constants.dart):
```dart
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';
```

### 14. Pemanggilan GET Melalui Fungsi Asynchronous
Fungsi `fetchCourses()` dibuat sementara pada [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart) (akan dipindahkan ke service pada Tahap 4):
```dart
Future<List<dynamic>> fetchCourses([String url = apiUrl]) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  throw Exception('HTTP ${response.statusCode}');
}
```

### 15. Tampilkan Jumlah Item pada debugPrint atau UI
Hasil eksekusi `fetchCourses()` dipanggil di `_MainPageState.initState()`:
- **Output `debugPrint`:**
  ```text
  [Tahap 2 HTTP GET] Status: 200 OK
  [Tahap 2 HTTP GET] Jumlah item mata kuliah: 14
  ```
- **Tampilan UI:** Ditampilkan status banner hijau pada bagian atas konten utama (`Tahap 2 HTTP GET: GET 200 OK (14 items)`).

### 16. Ubah Sementara Endpoint Menjadi Salah (Melihat Error)
- Endpoint diubah sementara ke: `https://course-api-pearl.vercel.app/courses_salah`
- **Hasil Respons:**
  - Status Code: `404 Not Found`
  - Exception tertangkap: `Exception: HTTP 404`
- **Output `debugPrint`:**
  ```text
  [Tahap 2 HTTP GET] Terjadi kesalahan: Exception: HTTP 404
  ```
- **Tampilan UI:** Status banner berubah menjadi merah (`Tahap 2 HTTP GET: Error: Exception: HTTP 404`).

### 17. Kembalikan Endpoint ke URL yang Benar
- Endpoint dikembalikan ke URL semula: `https://course-api-pearl.vercel.app/courses`
- **Hasil:** Request kembali sukses (`Status 200 OK`), mengembalikan `14` item mata kuliah dalam format `List<dynamic>`.

---

## Tahap 3 — Model Dart: Course.fromJson() dan toJson()

### 18. Pembaruan Model Course & Method `toJson()`
File [lib/models/course.dart](file:///c:/src/flutter_ui_fundamentals/lib/models/course.dart) diperbarui:
- Mempertahankan field `code`, `title`, `credits`, `status`, dan `category`.
- Menambahkan field `id` bernilai nullable (`int?`).
- Menambahkan konstruktor `const` dengan nilai default `status = 'planned'`.
- Menambahkan method `toJson()` untuk serialisasi object kembali ke format Map JSON:
  ```dart
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'code': code,
    'title': title,
    'credits': credits,
    'status': status,
    'category': category,
    if (createdAt != null) 'created_at': createdAt,
  };
  ```

### 19. Nilai Default 'planned' pada `fromJson()`
Jika key `status` bernilai `null` atau tidak dikirim oleh API:
```dart
status: (json['status'] as String?) ?? 'planned',
```

### 20. Penyesuaian Nama Field dengan JSON API
Field JSON yang diterima dari endpoint REST API:
- `id`: dipetakan ke `int? id`
- `code`: dipetakan ke `String code`
- `title`: dipetakan ke `String title`
- `credits`: dipetakan ke `int credits`
- `status`: dipetakan ke `String status` (fallback: `'planned'`)
- `created_at`: dipetakan ke `String? createdAt`

### 21. Konversi Response List Menjadi `List<Course>`
Fungsi `fetchCourses()` pada [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart) mengonversi hasil JSON decoding menjadi daftar bertipe kuat (`List<Course>`):
```dart
final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
return data
    .map((item) => Course.fromJson(item as Map<String, dynamic>))
    .toList();
```

### 22. Tampilan Code, Title, dan Status Minimal Tiga Course pada UI
Pada [lib/screens/home_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/home_page.dart) dan [lib/widgets/course_card.dart](file:///c:/src/flutter_ui_fundamentals/lib/widgets/course_card.dart):
1. **Section Khusus Tahap 3 pada HomePage:** Menampilkan 3 course pertama yang berhasil dimuat dari REST API lengkap dengan `code`, `title`, dan status badge (`done`, `active`, `planned`).
2. **CourseCard Global:** Seluruh card mata kuliah kini menampilkan kombinasi `code • status` bersama judul course.
- Contoh 3 data pertama dari REST API:
  - `[MOB04]` State Management Provider — status: `planned`
  - `[MOB05]` REST API & Database — status: `done`
  - `[MOB02]` Dart — status: `active`

---

## Tahap 4 — Memindahkan HTTP ke Service Layer

Screen tidak seharusnya berisi detail request HTTP. Data source/service bertanggung jawab berkomunikasi dengan backend sesuai arsitektur integrasi:
`Presentation (Screen/Widget) -> State/Controller (Provider) -> Repository -> Service/Data Source -> Backend & Database`.

### 23. Pembuatan `lib/services/course_api_service.dart`
Membuat class `CourseApiService` yang bertanggung jawab melakukan HTTP GET ke REST API dan mengonversi response JSON menjadi `List<Course>`:
```dart
class CourseApiService {
  CourseApiService([String? baseUrl])
      : baseUrl = baseUrl ?? 'https://course-api-pearl.vercel.app';

  final String baseUrl;

  Future<List<Course>> getCourses() async {
    final endpoint = baseUrl.endsWith('/courses')
        ? baseUrl
        : '$baseUrl/courses';
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course');
    }

    final List data = jsonDecode(response.body) as List;
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

### 24. Pembaruan Dependency `CourseRepository`
Dependency [lib/repositories/course_repository.dart](file:///c:/src/flutter_ui_fundamentals/lib/repositories/course_repository.dart) diubah dari `CourseService` menjadi `CourseApiService`, dan pemanggilan method disesuaikan dari `loadCourses()` menjadi `getCourses()`:
```dart
class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses({bool simulateError = false}) {
    if (simulateError) {
      throw Exception('Gagal memuat data dari CourseApiService (Simulasi Kasus C)');
    }
    return service.getCourses();
  }
}
```

### 25. Penghapusan `lib/services/course_service.dart`
File `lib/services/course_service.dart` dihapus dari pelacakan git menggunakan:
```bash
git rm lib/services/course_service.dart
```

### 26. Pemindahan Seluruh Kode GET dari UI ke Service
Logika `http.get` dan deserialisasi `jsonDecode` yang sebelumnya ada di UI [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart) sepenuhnya dipindahkan ke `CourseApiService`. File `main.dart` tidak lagi mengimpor package `http` maupun `dart:convert`.

### 27. Screen Hanya Memanggil Service/Repository Melalui Provider
Screen (`MainPage`, `HomePage`, `CoursesPage`) kini hanya memanggil `CourseProvider`, yang mengelola state data dari `CourseRepository` dan `CourseApiService`. UI menjadi bersih dan terpisah dari implementasi backend.

### 28. Menjalankan Kembali Aplikasi dan Pengujian
Seluruh pengujian (`test/tahap2_http_test.dart`, `test/tahap3_model_test.dart`, `test/tahap4_service_test.dart`, dan `test/widget_test.dart`) berhasil dijalankan dengan hasil **100% lulus (All tests passed)**.

---

## Tahap 5 — Loading, Success, Empty, dan Error State

Request jaringan bersifat asynchronous sehingga UI harus memiliki penanganan state yang eksplisit:
1. **Loading** → Menampilkan progress indicator (`CircularProgressIndicator`).
2. **Success** → Menampilkan daftar data course yang berhasil dimuat.
3. **Empty** → Menampilkan pesan informatif bahwa data course belum tersedia (`Data course belum tersedia`).
4. **Error** → Menampilkan pesan kesalahan dan tombol retry melalui widget `ErrorView`.

```dart
final provider = context.watch<CourseProvider>();

if (provider.isLoading) {
  return const Center(child: CircularProgressIndicator());
}

if (provider.error != null) {
  return ErrorView(
    message: provider.error!,
    onRetry: provider.loadCourses,
  );
}

if (provider.courses.isEmpty) {
  return const Center(child: Text('Data course belum tersedia'));
}
```

### 29. Perluasan `CourseProvider`
[lib/providers/course_provider.dart](file:///c:/src/flutter_ui_fundamentals/lib/providers/course_provider.dart) mempertahankan field `courses`, `isLoading`, dan `error`, serta ditambahkan helper:
- `bool get isEmpty => courses.isEmpty;`
- `bool get hasData => courses.isNotEmpty;`
- `bool get hasError => error != null;`
- Dukungan parameter `simulateEmpty: true` untuk pengujian Empty State.

### 30. Pembuatan Widget `ErrorView`
File baru [lib/widgets/error_view.dart](file:///c:/src/flutter_ui_fundamentals/lib/widgets/error_view.dart) dibuat untuk menampilkan icon peringatan, judul `Terjadi kesalahan:`, detail pesan error, dan tombol retry (`Coba Lagi`):
```dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Coba Lagi',
  });
...
```

### 31. Pemanggilan `loadCourses()` Sekali Saat Inisialisasi
Pada [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart), pemanggilan `loadCourses()` dilakukan sekali saat provider dibuat menggunakan cascade notation:
```dart
ChangeNotifierProvider<CourseProvider>(
  create: (_) => CourseProvider()..loadCourses(),
  child: const MyApp(),
)
```
Pemanggilan dipastikan tidak pernah diletakkan di dalam fungsi `build()` agar tidak terjadi infinite request loop.

### 32. Simulasi Endpoint Salah & Dokumentasi Error UI
- **Skenario:** Endpoint diubah sementara menjadi salah (misal: `https://course-api-pearl.vercel.app/endpoint_salah` atau `simulateError: true`).
- **Respon Backend:** HTTP 404 / Exception.
- **Tampilan UI:** 
  - `CoursesPage` langsung menampilkan widget `ErrorView` berwarna merah dengan icon error, teks `Terjadi kesalahan:\nException: Gagal mengambil course`, dan tombol `Coba Lagi`.
  - Banner status di bagian atas menampilkan status merah `Error: Exception: Gagal mengambil course`.

### 33. Kembalikan Endpoint Benar dan Refresh
- **Aksi:** Endpoint dikembalikan ke URL valid (`https://course-api-pearl.vercel.app/courses`) dan tombol `Coba Lagi` ditekan.
- **Hasil:** UI segera bertransisi dari Error State ke Loading State (`CircularProgressIndicator`), lalu masuk ke **Success State** dengan menampilkan seluruh card course secara responsif.

---

## Tahap 6 — HTTP POST: Membuat Resource Baru

Menambahkan fitur pembuatan resource data course baru menggunakan HTTP POST dengan arsitektur berlapis:
`Presentation (Screen/Form) -> State/Controller (Provider) -> Repository -> Service/Data Source -> Backend`.

### 34. Pembuatan Form Tambah Course
File baru [lib/screens/add_course_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/add_course_page.dart) dibuat dengan field input:
- `code`: Kode mata kuliah (TextFormField).
- `title`: Judul mata kuliah (TextFormField).
- `credits`: Jumlah SKS (TextFormField bertipe angka).
- `status`: Pilihan status mata kuliah (`planned`, `active`, `done`) menggunakan `DropdownButtonFormField`.

### 35. Validasi Form
- Validasi wajib diisi untuk seluruh field utama (`code`, `title`, `credits`, `status`).
- Validasi `credits` memastikan nilai yang dimasukkan berupa angka positif (`int.tryParse(value) != null && parsed > 0`).

### 36. Pengiriman Data Melalui Service Layer dan Provider
Alur data mengikuti arsitektur:
1. `CourseApiService.createCourse(Course course)` melakukan `http.post` ke endpoint `$baseUrl/courses` dengan header `Content-Type: application/json` dan body `jsonEncode(course.toJson())`.
2. `CourseRepository.createCourse(Course course)` mendelegasikan request ke `CourseApiService`.
3. `CourseProvider.createCourse(Course course)` memanggil repository dan mengelola state asynchronous.
4. Screen tidak pernah mengimpor atau memanggil package `http` secara langsung.

### 37. Pencegahan Submit Ganda (Flag `isSaving`)
- Flag `isSaving` aktif selama request berlangsung.
- Tombol `Simpan Course` dinonaktifkan (`onPressed: _isSaving ? null : _submit`) dan menampilkan `CircularProgressIndicator` untuk mencegah duplicate submission atau data ganda.

### 38. Feedback Pengguna Melalui SnackBar
- Menampilkan `SnackBar` hijau bertuliskan `Course berhasil ditambahkan!` jika request berhasil.
- Menampilkan `SnackBar` merah dengan detail pesan kegagalan jika terjadi error.

### 39. Pemeriksaan `context.mounted`
Sebelum memanggil `ScaffoldMessenger` atau `Navigator.pop(context)` setelah operasi `await`, dilakukan pemeriksaan keamanan:
```dart
if (!context.mounted) return;
```

### 40. Refresh List Otomatis
Setelah penambahan data berhasil, `CourseProvider` otomatis memanggil `await loadCourses()` untuk memperbarui seluruh daftar course dari backend (mengganti isi list, bukan sekadar append lokal).

---

## Tahap 7 — HTTP PUT/PATCH: Memperbarui Resource

Menambahkan fitur pembaruan resource data course yang ada melalui metode HTTP PUT dengan arsitektur berlapis:
`Presentation (Screen/Form) -> State/Controller (Provider) -> Repository -> Service/Data Source -> Backend`.

### 41. Tombol Edit pada Course Detail
Pada [lib/screens/course_detail_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_detail_page.dart), ditambahkan tombol `Edit Course` pada AppBar (`IconButton`) dan di bawah detail card (`ElevatedButton.icon`) yang mengarahkan pengguna ke halaman edit.

### 42. Form Edit dengan Data Lama & Field Code Read-Only
File baru [lib/screens/edit_course_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/edit_course_page.dart) dibuat untuk memfasilitasi pengeditan:
- Mengisi controller form dengan data course lama (`title`, `credits`, `status`).
- Field `code` dibuat **read-only** (`readOnly: true`) dengan tampilan terkunci karena dipakai sebagai kunci favorites pada state management.

### 43. Pengiriman Perubahan via PUT Melalui Service Layer
- `CourseApiService.updateCourse(int id, Course course)` melakukan request `http.put` ke endpoint `$baseUrl/courses/$id` dengan header `Content-Type: application/json` dan body `jsonEncode(course.toJson())`.
- Method melempar `Exception('Gagal memperbarui course')` jika status code bukan 2xx (status < 200 atau >= 300).
- Pemanggilan diteruskan secara berurutan: `EditCoursePage -> CourseProvider -> CourseRepository -> CourseApiService`.

### 44. Guard Submit Ganda & Pemeriksaan `context.mounted`
- Tombol `Simpan Perubahan` dinonaktifkan dan menampilkan `CircularProgressIndicator` saat request update berjalan (`isSaving`).
- Pemeriksaan keamanan `if (!context.mounted) return;` dilakukan setelah `await` sebelum menampilkan `SnackBar` atau menutup dialog/halaman melalui `Navigator.pop()`.

### 45. Refresh Data Otomatis & Tampilan Hasil
Setelah request PUT berhasil, `CourseProvider` memanggil `await loadCourses()` untuk me-refresh data course dari backend. Halaman `CourseDetailPage` yang mengamati `CourseProvider` otomatis terbarui secara reaktif, dan `SnackBar` hijau ditampilkan sebagai feedback keberhasilan.

---

## Tahap 8 — HTTP DELETE: Menghapus Resource

Menambahkan fitur penghapusan resource data course menggunakan HTTP DELETE dengan konfirmasi dialog dan pembersihan data relasional (favorites):
`Presentation (Screen/Dialog) -> State/Controller (Provider) -> Repository -> Service/Data Source -> Backend`.

### 46. Tombol Delete pada UI
Pada [lib/screens/course_detail_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_detail_page.dart), ditambahkan tombol `Hapus Course` pada AppBar (`IconButton`) dan tombol outline berwarna merah pada card detail.

### 47. AlertDialog Konfirmasi Sebelum Menghapus
Sebelum request DELETE dikirimkan, aplikasi menampilkan `AlertDialog` konfirmasi berisi:
- Judul: `Konfirmasi Hapus` dengan icon peringatan.
- Konten: Pertanyaan konfirmasi menghapus course bersangkutan (`Apakah Anda yakin ingin menghapus course ...?`).
- Aksi: Tombol `Batal` (menutup dialog tanpa menghapus) dan tombol merah `Hapus` (menyetujui penghapusan).

### 48. Eksekusi Request DELETE Setelah Persetujuan Pengguna
Jika user menekan tombol `Hapus`, request dikirim melalui:
1. `CourseApiService.deleteCourse(int id)` melakukan request `http.delete` ke endpoint `$baseUrl/courses/$id`.
2. Method memeriksa status respons (sukses jika status >= 200 dan < 300; selain itu melempar exception).
3. Pemanggilan diteruskan melalui `CourseRepository.deleteCourse(id)` dan `CourseProvider.deleteCourse(id)`.

### 49. Refresh List dan Feedback SnackBar
Setelah penghapusan sukses, `CourseProvider` otomatis memanggil `await loadCourses()` untuk me-refresh data course dari backend, dan `SnackBar` merah ditampilkan bertuliskan `Course berhasil dihapus!`. Halaman detail kemudian ditutup dengan `Navigator.pop(context)` untuk kembali ke daftar course.

### 50. Pemeriksaan `context.mounted`
Pemeriksaan keamanan dilakukan setelah proses async `showDialog` dan `await deleteCourse`:
```dart
if (!context.mounted) return;
```
sebelum context digunakan untuk menampilkan `SnackBar` maupun navigasi.

### 51. Pembersihan Otomatis dari Favorites (Mencegah Data Yatim)
Sebelum atau saat course dihapus dari backend, `CourseProvider.deleteCourse` memeriksa apakah course tersebut tercatat dalam himpunan `favorites`. Jika ada, kode course dihapus dari `favorites` (`favorites.remove(code)`), sehingga tidak tersisa data yatim pada daftar favorit.

---

## Tahap 9 — Repository Pattern untuk REST API

Menerapkan Repository Pattern sebagai kontrak abstraksi antara data source dan state layer:
`Presentation (Screen/Form) -> State/Controller (Provider) -> Repository -> Data Source Contract (CourseDataSource) -> CourseApiService -> Backend`.

### 52. Kontrak Sumber Data `CourseDataSource`
Membuat file baru [lib/services/course_data_source.dart](file:///c:/src/flutter_ui_fundamentals/lib/services/course_data_source.dart) berupa abstract class:
```dart
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}
```
Dan mengubah deklarasi [lib/services/course_api_service.dart](file:///c:/src/flutter_ui_fundamentals/lib/services/course_api_service.dart) menjadi:
```dart
class CourseApiService implements CourseDataSource {
  ...
}
```

### 53. Pembaruan `CourseRepository`
Dependency pada [lib/repositories/course_repository.dart](file:///c:/src/flutter_ui_fundamentals/lib/repositories/course_repository.dart) diubah dari implementasi konkret menjadi abstraksi `CourseDataSource`:
```dart
class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  Future<List<Course>> getCourses({bool simulateError = false}) {
    if (simulateError) {
      throw Exception('Gagal memuat data dari CourseApiService (Simulasi Kasus C)');
    }
    return dataSource.getCourses();
  }

  Future<Course> createCourse(Course course) =>
      dataSource.createCourse(course);

  Future<void> updateCourse(int id, Course course) =>
      dataSource.updateCourse(id, course);

  Future<void> deleteCourse(int id) =>
      dataSource.deleteCourse(id);
}
```

### 54. Isolasi `CourseProvider`
`CourseProvider` hanya menerima `CourseRepository` melalui konstruktor dan hanya berkomunikasi melalui method repository tanpa mengetahui sumber data sebenarnya (REST API, cache, atau mock).

### 55. Perakitan Komponen di `main.dart`
Perakitan `service -> repository -> provider` dilakukan di [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart):
```dart
final repository = CourseRepository(CourseApiService(apiBaseUrl));

runApp(
  ChangeNotifierProvider<CourseProvider>(
    create: (_) => CourseProvider(repository)..loadCourses(),
    child: const MyApp(),
  ),
);
```
Dengan struktur ini, ketika sumber data diganti (misalnya ke Cache atau Local Database), hanya baris inisialisasi tersebut yang perlu diubah.

### 56. Pembersihan Import HTTP
Dipastikan tidak ada `import 'package:http/http.dart'` pada screen maupun provider. Package `http` hanya diimpor di `CourseApiService`.

### 57. Pengujian Menyeluruh
Seluruh operasi CRUD (GET, POST, UPDATE, DELETE) telah diuji dan berhasil dijalankan melalui kontrak Repository Pattern.



