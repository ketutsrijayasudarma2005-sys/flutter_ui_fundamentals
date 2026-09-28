import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

// ===============================
// DASHBOARD PAGE
// ===============================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();

    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // DATA KOSONG
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak tersedia'),
            );
          }

          final data = snapshot.data!;

          final student =
              data['student'] as Map<String, dynamic>;

          final courses =
              data['courses'] as List<dynamic>;

          final String name =
              student['name'] as String;

          final String nim =
              student['nim'] as String;

          // Menghitung ringkasan
          final int totalCourses = courses.length;

          final int completedCourses = courses
              .where(
                (course) =>
                    course['status'] == 'done',
              )
              .length;

          final int totalCredits = courses.fold(
            0,
            (total, course) =>
                total +
                (course['credits'] as int),
          );

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ===============================
                // PROFILE
                // ===============================

                buildProfileCard(
                  name,
                  nim,
                ),

                const SizedBox(height: 16),

                // ===============================
                // SUMMARY
                // ===============================

                Row(
                  children: [
                    Expanded(
                      child: buildSummaryCard(
                        icon: Icons.menu_book,
                        title: 'Mata Kuliah',
                        value: '$totalCourses',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: buildSummaryCard(
                        icon: Icons.school,
                        title: 'Total SKS',
                        value: '$totalCredits',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // SUMMARY TAMBAHAN
                buildSummaryCard(
                  icon: Icons.check_circle,
                  title: 'Materi Selesai',
                  value:
                      '$completedCourses dari $totalCourses',
                ),

                const SizedBox(height: 20),

                const Text(
                  'Daftar Materi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // ===============================
                // COURSE LIST
                // ===============================

                ...courses.map(
                  (course) {
                    final item =
                        course as Map<String, dynamic>;

                    return buildCourseCard(item);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===============================
// REUSABLE PROFILE WIDGET
// ===============================

Widget buildProfileCard(
  String name,
  String nim,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Image.asset(
            'assets/images/image.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(nim),

                const SizedBox(height: 4),

                const Text(
                  'Mobile Programming Student',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ===============================
// REUSABLE SUMMARY WIDGET
// ===============================

Widget buildSummaryCard({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ===============================
// REUSABLE COURSE CARD
// ===============================

Widget buildCourseCard(
  Map<String, dynamic> course,
) {
  final String status =
      course['status'] as String;

  IconData icon;
  String statusText;

  if (status == 'done') {
    icon = Icons.check_circle;
    statusText = 'Selesai';
  } else if (status == 'active') {
    icon = Icons.play_circle;
    statusText = 'Aktif';
  } else {
    icon = Icons.schedule;
    statusText = 'Rencana';
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon),

      title: Text(
        course['title'] as String,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        '${course['code']} • '
        '${course['credits']} SKS\n'
        '${course['category']}',
      ),

      isThreeLine: true,

      trailing: Text(statusText),
    ),
  );
}