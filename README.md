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

---

## Tahap 12 — SELECT: Membaca Data dari Database (Supabase)

### 71. Membuat `lib/services/course_supabase_service.dart`
Membuat class `CourseSupabaseService` yang mengimplementasikan `CourseDataSource`. Untuk method yang belum diimplementasikan (`createCourse`, `updateCourse`, `deleteCourse`), sementara melempar `UnimplementedError()`:
```dart
class CourseSupabaseService implements CourseDataSource {
  CourseSupabaseService([SupabaseClient? client]) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get supabase => _client ?? Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Sementara, agar kelas tetap dapat dikompilasi:
  @override
  Future<Course> createCourse(Course course) => throw UnimplementedError();

  @override
  Future<void> updateCourse(int id, Course course) => throw UnimplementedError();

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}
```

### 72 & 73. Query Data dari Tabel `courses` dan Konversi Response ke `List<Course>`
Mengambil data dari tabel `courses` di Supabase dengan method:
```dart
final data = await supabase
    .from('courses')
    .select()
    .order('id');
```
Kemudian response dikonversi menjadi `List<Course>` melalui factory constructor `Course.fromJson`:
```dart
return (data as List)
    .map((e) => Course.fromJson(e as Map<String, dynamic>))
    .toList();
```

### 74. Menampilkan Data pada ListView/GridView
Mengintegrasikan `CourseSupabaseService` ke dalam `CourseRepository` dan `CourseProvider`. Pada [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart):
```dart
final repository = CourseRepository(CourseSupabaseService());
```
Data course dari Supabase ditampilkan secara responsif pada `GridView.builder` di `CoursesPage` dan `ListView` di `HomePage`.

### 75. Memastikan Identitas Mahasiswa Tetap Tampil
Identitas mahasiswa tetap dipertahankan dan ditampilkan pada header `HomePage` dan `ProfilePage`:
- **Nama:** I Ketut Srijaya Sudarma
- **NIM:** 2415051063
- **Kelas:** PTI 5A

---

## Tahap 13 — INSERT: Menambah Data ke Database (Supabase)

### 76 & 77. Form Create Course & Validasi Field
Menggunakan form `AddCoursePage` ([lib/screens/add_course_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/add_course_page.dart)) untuk input data mata kuliah baru:
- Field `code`: Wajib diisi (tidak boleh kosong).
- Field `title`: Wajib diisi (tidak boleh kosong).
- Field `credits`: Wajib diisi dan harus berupa angka positif.
- Field `status`: Pilihan dropdown (`planned`, `active`, `done`).

### 78. Method `createCourse` pada `CourseSupabaseService`
Mengganti stub `createCourse` pada [lib/services/course_supabase_service.dart](file:///c:/src/flutter_ui_fundamentals/lib/services/course_supabase_service.dart) dengan pemanggilan query insert ke tabel `courses`:
```dart
@override
Future<Course> createCourse(Course course) async {
  final row = await supabase
      .from('courses')
      .insert(course.toJson())
      .select()
      .single();

  return Course.fromJson(row);
}
```
Method mengembalikan object `Course` baru yang memiliki `id` dari database sehingga kontrak `CourseDataSource` dan `CourseRepository` tetap konsisten tanpa perubahan arsitektur.

### 79. Refresh List Otomatis
Setelah penambahan data berhasil melalui `CourseProvider.createCourse`, fungsi `loadCourses()` otomatis dipanggil untuk me-refresh data course pada aplikasi (mengganti isi list, bukan sekadar append).

### 80. Verifikasi Row Baru
Data baru dapat diverifikasi langsung pada aplikasi (di `HomePage`, `CoursesPage`, dan daftar card) serta di dashboard database Supabase.

---

## Tahap 14 — UPDATE: Mengubah Data di Database (Supabase)

### 81. Edit Course dari Halaman Detail
Aksi Edit Course tersedia pada halaman detail ([lib/screens/course_detail_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_detail_page.dart)) melalui ikon pensil pada AppBar maupun tombol "Edit Course" di dalam body halaman detail.

### 82. Mengubah Title, Credits, dan Status
Form edit pada [lib/screens/edit_course_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/edit_course_page.dart) memuat data lama mata kuliah:
- Field `code`: Bersifat read-only (kunci favorites).
- Field `title`: Dapat diubah dan divalidasi tidak boleh kosong.
- Field `credits`: Dapat diubah dan divalidasi harus berupa angka positif.
- Field `status`: Pilihan dropdown (`planned`, `active`, `done`).

### 83. Method `updateCourse` pada `CourseSupabaseService`
Mengganti stub `updateCourse` pada [lib/services/course_supabase_service.dart](file:///c:/src/flutter_ui_fundamentals/lib/services/course_supabase_service.dart):
```dart
@override
Future<void> updateCourse(int id, Course course) async {
  await supabase
      .from('courses')
      .update(course.toJson())
      .eq('id', id);
}
```
Signature method `Future<void> updateCourse(int id, Course course)` sama persis dengan kontrak `CourseDataSource`.

### 84. Refresh List Otomatis
`CourseProvider.updateCourse` mengeksekusi pembaruan ke repository lalu otomatis memanggil `await loadCourses()`, sehingga list data ter-refresh secara real-time.

### 85. Verifikasi Perubahan
Perubahan data diverifikasi langsung pada antarmuka aplikasi (`HomePage`, `CoursesPage`, `DetailPage`) dan tersimpan secara persisten pada tabel database Supabase.

---

## Tahap 15 — DELETE: Menghapus Data dari Database (Supabase)

### 86. Dialog Konfirmasi Penghapusan
Pada halaman detail ([lib/screens/course_detail_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_detail_page.dart)), ketika tombol "Hapus Course" ditekan, aplikasi memunculkan `AlertDialog` konfirmasi ("Konfirmasi Hapus") dengan opsi:
- **Batal:** Membatalkan aksi penghapusan.
- **Hapus:** Melanjutkan proses penghapusan data secara permanen dari database.

### 87. DELETE Berdasarkan ID
Mengganti stub `deleteCourse` pada [lib/services/course_supabase_service.dart](file:///c:/src/flutter_ui_fundamentals/lib/services/course_supabase_service.dart) dengan pemanggilan query delete:
```dart
@override
Future<void> deleteCourse(int id) async {
  await supabase
      .from('courses')
      .delete()
      .eq('id', id);
}
```
Signature `Future<void> deleteCourse(int id)` sesuai dengan kontrak `CourseDataSource`.

### 88. Refresh List Otomatis
Setelah penghapusan berhasil melalui `CourseProvider.deleteCourse(id)`, pemanggilan `await loadCourses()` otomatis dijalankan untuk me-refresh data course pada aplikasi secara real-time.

### 89. Verifikasi Data Hilang dari UI dan Database
- **Aplikasi:** Data yang dihapus tidak lagi tampil pada `HomePage`, `CoursesPage`, dan `FavoritesPage`. SnackBar "Course berhasil dihapus!" ditampilkan kepada pengguna.
- **Database Supabase:** Baris data dengan `id` terkait terhapus secara permanen dari tabel `courses`.

---

## Tahap 16 — Mini Project Integrasi: Course Data Manager

### 90. Pemisahan Layer: Provider Bebas dari Detail HTTP/Supabase
Pada [lib/providers/course_provider.dart](file:///c:/src/flutter_ui_fundamentals/lib/providers/course_provider.dart), `CourseProvider` hanya bergantung pada abstraksi `CourseRepository` dan model `Course`. Tidak ada import langsung package `http` maupun `supabase_flutter`. Hal ini menjamin prinsip *Clean Architecture* dan kemudahan pengujian (*testability*).

### 91. Screen Bebas dari Query Database Langsung
Seluruh screen ([lib/screens/course_list_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_list_page.dart), [lib/screens/course_form_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_form_page.dart), [lib/screens/course_detail_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/course_detail_page.dart), [lib/screens/favorites_page.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/favorites_page.dart)) berkomunikasi secara eksklusif melalui `CourseProvider` menggunakan `context.watch<CourseProvider>()` dan `context.read<CourseProvider>()`. Tidak ada pemanggilan langsung ke SQL atau Supabase Client dari sisi UI.

### 92. Pemilihan Data Source Aktif Hanya di `main.dart`
Pergantian sumber data (antara REST API dan Database Supabase) dapat dilakukan hanya dengan mengubah satu baris deklarasi `CourseDataSource` pada [lib/main.dart](file:///c:/src/flutter_ui_fundamentals/lib/main.dart):
```dart
// lib/main.dart — data source aktif: Supabase
// (untuk REST: CourseApiService(apiBaseUrl))
final CourseDataSource dataSource = CourseSupabaseService();
final repository = CourseRepository(dataSource);

runApp(
  ChangeNotifierProvider(
    create: (_) => CourseProvider(repository)..loadCourses(),
    child: const MyApp(),
  ),
);
```

### 93. Penggunaan Kembali Service Layer Melalui Kontrak `CourseDataSource`
`CourseApiService` (hasil Tahap 2–9) dan `CourseSupabaseService` (hasil Tahap 12–15) keduanya mengimplementasikan kontrak `CourseDataSource`. Keduanya dapat saling menggantikan tanpa memengaruhi layer repository, provider, maupun UI screen.

### 94. Pengujian Seluruh Operasi CRUD (Create, Read, Update, Delete)
Operasi CRUD telah teruji dan terintegrasi secara menyeluruh:
1. **Read/SELECT:** Data dimuat dari tabel `courses` menggunakan query `supabase.from('courses').select().order('id')` dan ditampilkan pada `CourseListPage`.
2. **Create/INSERT:** Form input pada `CourseFormPage` memvalidasi input (`code`, `title`, `credits`, `status`) dan mengirimkan data baru ke database melalui `provider.createCourse`.
3. **Edit/UPDATE:** Form edit pada `CourseFormPage` memuat data lama dengan `code` bertipe read-only, lalu memperbarui data di database melalui `provider.updateCourse`.
4. **Delete dengan Konfirmasi:** Terdapat dialog konfirmasi `AlertDialog` sebelum eksekusi `provider.deleteCourse(id)`, dengan penghapusan otomatis dari daftar `favorites` agar tidak meninggalkan data yatim.

### 95. Penanganan State Asynchronous & Uji Error State
Aplikasi menangani 4 kemungkinan state UI:
- **Loading State:** Menampilkan indikator loading saat memuat data atau memproses simpan/hapus.
- **Empty State:** Menampilkan tampilan informatif saat belum ada course di database beserta tombol ajakan tambah course.
- **Error State & Retry:** Menampilkan komponen [lib/widgets/error_view.dart](file:///c:/src/flutter_ui_fundamentals/lib/widgets/error_view.dart) lengkap dengan pesan kesalahan dan tombol "Coba Lagi" (`loadCourses()`).
- **Feedback SnackBar:** Menampilkan notifikasi visual pada setiap aksi sukses maupun gagal.

### Fitur Tambahan & Responsivitas
- **Responsive Shell ([lib/screens/responsive_shell.dart](file:///c:/src/flutter_ui_fundamentals/lib/screens/responsive_shell.dart)):** Menyesuaikan navigasi secara otomatis: `NavigationBar` pada ponsel (< 840px) dan `NavigationRail` pada layar lebar (>= 840px).
- **Konsistensi Favorites:** Menggunakan `code` sebagai kunci unik dan tetap sinkron di berbagai screen bahkan setelah pemanggilan refresh database.
- **Identitas Mahasiswa:**
  - **Nama:** I Ketut Srijaya Sudarma
  - **NIM:** 2415051063
  - **Kelas:** PTI 5A








