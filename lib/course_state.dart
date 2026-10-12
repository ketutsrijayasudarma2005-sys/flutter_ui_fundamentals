import 'package:flutter/foundation.dart';
import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository _repository;
  final Set<String> favorites = {};
  List<Course> _courses = [];
  bool _isLoading = false;

  CourseState({CourseRepository? repository})
      : _repository = repository ?? CourseRepository(CourseService());

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  bool isFavorite(String id) {
    return favorites.contains(id);
  }

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
  }

  // 45. Provider memanggil repository.getCourses()
  Future<List<Course>> loadCourses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _courses = await _repository.getCourses();
      debugPrint('CourseRepository: Berhasil memuat ${_courses.length} course.');
      return _courses;
    } catch (e) {
      debugPrint('CourseRepository Error: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

