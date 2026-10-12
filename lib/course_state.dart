import 'package:flutter/foundation.dart';

class CourseState extends ChangeNotifier {
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
}

typedef CourseProvider = CourseState;
