//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider([CourseRepository? repository])
      : repository = repository ?? CourseRepository(CourseService());

  List<Course> courses = [];
  bool isLoading = false;
  String? error;
  final Set<String> favorites = {};

  bool isFavorite(String code) => favorites.contains(code);

  void toggleFavorite(String code) {
    favorites.contains(code)
        ? favorites.remove(code)
        : favorites.add(code);
    notifyListeners();
  }

  // 67. Kasus C: Mengelola error state jika service mengalami kendala
  Future<void> loadCourses({bool simulateError = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      courses = await repository.getCourses(simulateError: simulateError);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

typedef CourseState = CourseProvider;
