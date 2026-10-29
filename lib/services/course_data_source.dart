//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import '../models/course.dart';

// 52. Kontrak sumber data (CourseDataSource)
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}

