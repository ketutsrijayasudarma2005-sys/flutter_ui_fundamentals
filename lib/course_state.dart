import 'package:flutter/foundation.dart';
import 'models/course.dart';
import 'services/course_service.dart';

class CourseState extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  final Set<String> favorites = {};
  List<Course> _courses = [];
  bool _isLoading = false;

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

  // 41. Uji service melalui Provider atau debugPrint sementara
  Future<List<Course>> loadCourses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _courses = await _courseService.loadCourses();
      debugPrint('CourseService: Berhasil memuat ${_courses.length} course dari assets/data/student_data.json');
      return _courses;
    } catch (e) {
      debugPrint('CourseService Error: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

