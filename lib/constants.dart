import 'package:flutter/material.dart';

const String studentName = 'I Ketut Srijaya Sudarma';
const String studentId = '2415051063';

// 13. Konstanta baseUrl & apiUrl sesuai endpoint latihan
const String baseUrl = 'https://course-api-pearl.vercel.app';
const String apiBaseUrl = baseUrl;
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

const Color primaryBlue = Color(0xFF1976D2);
const Color darkBlue = Color(0xFF173B63);
const Color backgroundColor = Color(0xFFF1F6FA);
const Color cardColor = Color(0xFFF9FCFF);
const Color navigationColor = Color(0xFFE4F1FC);
const Color borderColor = Color(0xFFC3D8E9);
const Color greenColor = Color(0xFF008F78);

const List<Map<String, dynamic>> courses = [
  {
    'code': 'MOB01',
    'title': 'Git & GitHub',
    'credits': 2,
    'status': 'done',
    'category': 'Version Control',
  },
  {
    'code': 'MOB02',
    'title': 'Dart Fundamentals',
    'credits': 2,
    'status': 'done',
    'category': 'Programming',
  },
  {
    'code': 'MOB03',
    'title': 'Flutter UI Fundamentals',
    'credits': 3,
    'status': 'active',
    'category': 'Flutter',
  },
  {
    'code': 'MOB04',
    'title': 'Navigation',
    'credits': 2,
    'status': 'planned',
    'category': 'Flutter',
  },
  {
    'code': 'MOB05',
    'title': 'State Management',
    'credits': 3,
    'status': 'planned',
    'category': 'Flutter',
  },
];
