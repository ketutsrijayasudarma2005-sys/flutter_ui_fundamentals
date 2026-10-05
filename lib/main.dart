import 'package:flutter/material.dart';

const String studentName = 'I Ketut Srijaya Sudarma';
const String studentId = '2415051063';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tahap 8 - Passing Data',
      home: const CoursePage(),
    );
  }
}

// HALAMAN UTAMA
class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  final List<Map<String, dynamic>> courses = const [
    {
      'code': 'MOB01',
      'title': 'Git & GitHub',
      'credits': 2,
      'status': 'done',
    },
    {
      'code': 'MOB02',
      'title': 'Dart Fundamentals',
      'credits': 2,
      'status': 'done',
    },
    {
      'code': 'MOB03',
      'title': 'Flutter UI Fundamentals',
      'credits': 3,
      'status': 'active',
    },
    {
      'code': 'MOB04',
      'title': 'Navigation',
      'credits': 2,
      'status': 'planned',
    },
    {
      'code': 'MOB05',
      'title': 'State Management',
      'credits': 3,
      'status': 'planned',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Course'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '$studentId - $studentName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(course['title']),
                    subtitle: Text(
                      '${course['code']} • ${course['credits']} SKS',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(
                            course: course,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// HALAMAN DETAIL
class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                '$studentId - $studentName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              course['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text('Kode Course : ${course['code']}'),
            const SizedBox(height: 10),

            Text('SKS : ${course['credits']}'),
            const SizedBox(height: 10),

            Text('Status : ${course['status']}'),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}