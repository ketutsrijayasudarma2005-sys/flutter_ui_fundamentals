import 'package:flutter/foundation.dart';
import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState([CourseRepository? repository])
      : repository = repository ?? CourseRepository(CourseService());

  List<Course> courses = [];
  bool isLoading = false;
  String? error;
  final Set<String> favorites = {};

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

  // 47. Implementasikan loadCourses()
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

typedef CourseProvider = CourseState;


