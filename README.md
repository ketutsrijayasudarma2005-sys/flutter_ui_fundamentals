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