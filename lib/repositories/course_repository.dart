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
}
