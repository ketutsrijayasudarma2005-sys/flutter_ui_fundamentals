import '../models/course.dart';
import '../services/course_data_source.dart';

// 53. Repository menggunakan CourseDataSource sebagai abstraksi sumber data
class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  CourseDataSource get service => dataSource;

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
