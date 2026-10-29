import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses({bool simulateError = false}) {
    if (simulateError) {
      throw Exception('Gagal memuat data dari CourseApiService (Simulasi Kasus C)');
    }
    return service.getCourses();
  }

  // Tahap 6: 36. Kirim data dengan POST melalui CourseApiService -> CourseRepository -> CourseProvider
  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }

  // Tahap 7: 43. Kirim perubahan menggunakan PUT/PATCH melalui CourseRepository
  Future<void> updateCourse(int id, Course course) {
    return service.updateCourse(id, course);
  }
}
