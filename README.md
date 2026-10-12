# Course Explorer v2 - Flutter UI Fundamentals

**Identitas Mahasiswa:**
- **Nama:** I Ketut Srijaya Sudarma
- **NIM:** 2415051063

---

## 🏛️ Arsitektur & Dependency Direction

Aplikasi Course Explorer v2 menerapkan pemisahan tanggung jawab (*Separation of Concerns*) dengan arah ketergantungan (*dependency direction*) satu arah:

$$\text{Screen / Widget} \longrightarrow \text{Provider} \longrightarrow \text{Repository} \longrightarrow \text{Service / Data Source}$$

1. **Screen / Widget**: Bertanggung jawab murni pada presentasi UI dan menangkap interaksi pengguna. UI tidak memanggil `rootBundle` atau `jsonDecode` secara langsung.
2. **Provider**: State holder aplikasi berbasis `ChangeNotifier` yang mengelola data, status loading, error, serta favorit. Provider tidak menyimpan `BuildContext`.
3. **Repository**: Lapisan abstraksi antara bisnis state dan sumber data, menyediakan kontrak data yang bersih untuk Provider.
4. **Service**: Menangani akses teknis ke sumber data (seperti membaca file asset melalui `rootBundle.loadString` dan parsing `jsonDecode`). Service bebas dari widget dan elemen UI.

---

## 📁 Tanggung Jawab Setiap Folder

Berikut adalah rincian tanggung jawab setiap folder pada project ini:

| Folder | Tanggung Jawab Singkat | Contoh File |
| :--- | :--- | :--- |
| `lib/models/` | Menyimpan representasi object model/entitas data terstruktur dan memusatkan serialisasi/deserialisasi JSON. | `course.dart` |
| `lib/services/` | Mengambil data mentah (*raw data*) dari sumber eksternal/asset lokal (`rootBundle`) dan mengubahnya menjadi object model. Bebas dari widget/UI. | `course_service.dart` |
| `lib/repositories/` | Menyediakan lapisan abstraksi data bagi Provider sehingga Provider tidak bergantung langsung pada implementasi teknis service/API. | `course_repository.dart` |
| `lib/providers/` | Mengelola *application state* (`courses`, `isLoading`, `error`, `favorites`) dan memicu pembaruan UI via `notifyListeners()`. Bebas dari `BuildContext`. | `course_provider.dart` |
| `lib/screens/` | Menampilkan halaman utama aplikasi serta mengatur tata letak, alur navigasi, dan merespons state dari Provider. | `home_page.dart`, `courses_page.dart`, `favorites_page.dart`, `course_detail_page.dart`, `profile_page.dart` |
| `lib/widgets/` | Berisi komponen UI modular yang dapat digunakan kembali (*reusable*) di berbagai halaman. | `course_card.dart`, `summary_card.dart` |

---

## 🔍 Hasil Audit Arsitektur (Tahap 16)

- **Poin 69 (Audit Screen):** Tidak ada screen yang memanggil `rootBundle` atau `jsonDecode` langsung. Seluruh data diakses melalui `CourseProvider`.
- **Poin 70 (Audit Service):** `CourseService` tidak mengimpor `material.dart` atau widget UI apa pun.
- **Poin 71 (Audit Provider):** `CourseProvider` tidak menyimpan `BuildContext` sebagai state variabel, mencegah potensi memory leak dan stale context.
- **Poin 72 (Dokumentasi):** Tanggung jawab setiap folder telah didokumentasikan secara lengkap pada file ini.
