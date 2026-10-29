//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../services/course_api_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider([CourseRepository? repository])
      : repository = repository ?? CourseRepository(CourseApiService());

  List<Course> courses = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  final Set<String> favorites = {};

  bool isFavorite(String code) => favorites.contains(code);

  void toggleFavorite(String code) {
    favorites.contains(code)
        ? favorites.remove(code)
        : favorites.add(code);
    notifyListeners();
  }

  // 29. Penanganan state asynchronous (Loading, Success, Empty, Error)
  bool get isEmpty => courses.isEmpty;
  bool get hasData => courses.isNotEmpty;
  bool get hasError => error != null;

  // 67. Kasus C & Tahap 5: Mengelola state asynchronous (loading, data, error, empty)
  Future<void> loadCourses({
    bool simulateError = false,
    bool simulateEmpty = false,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (simulateEmpty) {
        courses = [];
      } else {
        courses = await repository.getCourses(simulateError: simulateError);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 36. Kirim data POST melalui CourseApiService -> CourseRepository -> CourseProvider
  // 37. Mengelola state isSaving untuk mencegah submit ganda
  // 40. Refresh list setelah berhasil dengan memanggil loadCourses() (ganti isi list, bukan menambah)
  Future<Course> createCourse(Course course) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final created = await repository.createCourse(course);
      await loadCourses();
      return created;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Tahap 7: 43. Kirim perubahan menggunakan PUT/PATCH melalui CourseRepository
  // 44. Terapkan guard submit ganda (isSaving)
  // 45. Refresh data setelah update
  Future<void> updateCourse(int id, Course course) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await repository.updateCourse(id, course);
      await loadCourses();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Tahap 8: 48. Jalankan DELETE setelah user menyetujui
  // 49. Refresh list setelah berhasil
  // 51. Jika course yang dihapus ada di favorites, hapus juga dari favorites agar tidak tersisa data yatim
  Future<void> deleteCourse(int id, {String? code}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (code != null) {
        favorites.remove(code);
      }
      final courseToRemove = courses.cast<Course?>().firstWhere(
            (c) => c?.id == id,
            orElse: () => null,
          );
      if (courseToRemove != null) {
        favorites.remove(courseToRemove.code);
      }

      await repository.deleteCourse(id);
      await loadCourses();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

typedef CourseState = CourseProvider;
