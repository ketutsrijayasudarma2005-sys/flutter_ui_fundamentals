import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  final CourseService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses({bool simulateError = false}) {
    return service.loadCourses(simulateError: simulateError);
  }
}
