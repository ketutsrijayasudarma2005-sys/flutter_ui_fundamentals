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
      title: 'Tahap 12 - User Interaction',
      home: const InteractionPage(),
    );
  }
}

class InteractionPage extends StatefulWidget {
  const InteractionPage({super.key});

  @override
  State<InteractionPage> createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> {
  bool isFavorite = false;
  int tapCount = 0;

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 12 - Interaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '$studentId - $studentName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            // INKWELL
            InkWell(
              onTap: () {
                setState(() {
                  tapCount++;
                });
              },
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course ditekan lama'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.touch_app,
                        size: 70,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Flutter UI Fundamentals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Jumlah tap: $tapCount'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GESTURE DETECTOR
            GestureDetector(
              onDoubleTap: () {
                toggleFavorite();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Column(
                  children: [
                    Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 50,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFavorite
                          ? 'Course Favorit'
                          : 'Belum Favorit',
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Double tap untuk mengubah favorit',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON
            ElevatedButton.icon(
              onPressed: toggleFavorite,
              icon: Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              label: Text(
                isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Tambah ke Favorit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}