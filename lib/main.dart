import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/course.dart';
import 'providers/course_provider.dart';
import 'screens/course_detail_page.dart';
import 'screens/courses_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';

export 'constants.dart';

// 14. Panggil GET melalui function asynchronous (sementara; kode ini akan dipindahkan ke service pada Tahap 4)
Future<List<dynamic>> fetchCourses([String url = apiUrl]) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  throw Exception('HTTP ${response.statusCode}');
}

void main() {
  runApp(
    ChangeNotifierProvider<CourseProvider>(
      create: (_) => CourseProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer v2',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

// MAIN PAGE + RESPONSIVE NAVIGATION
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  String? tahap2StatusMessage;

  @override
  void initState() {
    super.initState();
    // 14 & 15. Panggil GET secara asynchronous dan tampilkan jumlah item pada debugPrint
    _loadTahap2Courses();

    // 60. Courses dimuat melalui Provider -> Repository -> Service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  Future<void> _loadTahap2Courses() async {
    try {
      final items = await fetchCourses();
      // 15. Tampilkan jumlah item pada debugPrint atau UI
      debugPrint('[Tahap 2 HTTP GET] Status: 200 OK');
      debugPrint('[Tahap 2 HTTP GET] Jumlah item mata kuliah: ${items.length}');
      if (mounted) {
        setState(() {
          tahap2StatusMessage = 'GET 200 OK (${items.length} items)';
        });
      }
    } catch (e) {
      debugPrint('[Tahap 2 HTTP GET] Terjadi kesalahan: $e');
      if (mounted) {
        setState(() {
          tahap2StatusMessage = 'Error: $e';
        });
      }
    }
  }

  void openDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(course: course),
      ),
    );
  }

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 64. Responsive navigation (NavigationRail pada layar lebar, NavigationBar pada mobile)
    final isExpanded = MediaQuery.sizeOf(context).width >= 840;
    final pages = [
      HomePage(onCourseTap: openDetail),
      CoursesPage(onCourseTap: openDetail),
      FavoritesPage(onCourseTap: openDetail),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer v2'),
        actions: [
          Consumer<CourseProvider>(
            builder: (context, state, _) {
              return IconButton(
                tooltip: 'Favorites',
                icon: Badge(
                  isLabelVisible: state.favorites.isNotEmpty,
                  label: Text('${state.favorites.length}'),
                  child: const Icon(Icons.favorite_border),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavoritesPage(onCourseTap: openDetail),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: openProfile,
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Eksperimen ValueNotifier',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ValueNotifierExperimentPage(),
                ),
              );
            },
            icon: const Icon(Icons.exposure_plus_1),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isExpanded)
              NavigationRail(
                backgroundColor: navigationColor,
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.book_outlined),
                    selectedIcon: Icon(Icons.book),
                    label: Text('Courses'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite_outline),
                    selectedIcon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
              ),
            Expanded(
              child: Column(
                children: [
                  if (tahap2StatusMessage != null)
                    Container(
                      width: double.infinity,
                      color: tahap2StatusMessage!.startsWith('Error')
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFE8F5E9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tahap2StatusMessage!.startsWith('Error')
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            size: 16,
                            color: tahap2StatusMessage!.startsWith('Error')
                                ? Colors.red.shade700
                                : const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tahap 2 HTTP GET: $tahap2StatusMessage',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tahap2StatusMessage!.startsWith('Error')
                                    ? Colors.red.shade800
                                    : const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: IndexedStack(index: selectedIndex, children: pages),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isExpanded
          ? null
          : NavigationBar(
              backgroundColor: navigationColor,
              indicatorColor: const Color(0xFFC7E2FA),
              selectedIndex: selectedIndex,
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
              ),
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: darkBlue),
                  selectedIcon: Icon(Icons.home, color: darkBlue),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book_outlined, color: darkBlue),
                  selectedIcon: Icon(Icons.book, color: darkBlue),
                  label: 'Courses',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_outline, color: darkBlue),
                  selectedIcon: Icon(Icons.favorite, color: darkBlue),
                  label: 'Favorites',
                ),
              ],
            ),
    );
  }
}

// TAHAP 4: EKSPERIMEN VALUENOTIFIER
class ValueNotifierExperimentPage extends StatefulWidget {
  const ValueNotifierExperimentPage({super.key});

  @override
  State<ValueNotifierExperimentPage> createState() =>
      _ValueNotifierExperimentPageState();
}

class _ValueNotifierExperimentPageState
    extends State<ValueNotifierExperimentPage> {
  final ValueNotifier<int> favoriteCounter = ValueNotifier<int>(0);

  @override
  void dispose() {
    favoriteCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksperimen ValueNotifier'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('NIM: $studentId'),
              const SizedBox(height: 24),
              const Text(
                'Jumlah Favorit Eksperimen',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<int>(
                valueListenable: favoriteCounter,
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => favoriteCounter.value++,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Favorit'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  if (favoriteCounter.value > 0) {
                    favoriteCounter.value--;
                  }
                },
                icon: const Icon(Icons.remove),
                label: const Text('Kurangi Favorit'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => favoriteCounter.value = 0,
                child: const Text('Reset Counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
