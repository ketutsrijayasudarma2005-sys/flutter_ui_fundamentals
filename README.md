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