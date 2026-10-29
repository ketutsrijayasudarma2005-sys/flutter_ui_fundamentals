import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/add_course_page.dart';
import 'screens/course_detail_page.dart';
import 'screens/edit_course_page.dart';
import 'screens/courses_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'services/course_api_service.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

export 'constants.dart';
export 'services/course_api_service.dart';
export 'services/course_data_source.dart';
export 'services/course_supabase_service.dart';

// 26. Seluruh kode GET telah dipindahkan ke CourseApiService.
// Fungsi fetchCourses didelegasikan ke CourseApiService untuk kompatibilitas pengujian
Future<List<Course>> fetchCourses([String url = apiUrl]) =>
    CourseApiService(url).getCourses();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.normalizedUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  // 55 & 74. Rakit service -> repository -> provider (CourseSupabaseService untuk database)
  final repository = CourseRepository(
    CourseSupabaseService(),
  );

  runApp(
    ChangeNotifierProvider<CourseProvider>(
      create: (_) => CourseProvider(repository)..loadCourses(),
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

  @override
  void initState() {
    super.initState();
    // 27. Screen hanya memanggil service/repository melalui CourseProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
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
      const ProfilePage(),
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
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
              ),
            Expanded(
              child: IndexedStack(index: selectedIndex, children: pages),
            ),
          ],
        ),
      ),
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton.extended(
              heroTag: 'add_course_fab',
              tooltip: 'Tambah Course',
              icon: const Icon(Icons.add),
              label: const Text('Tambah Course'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCoursePage()),
                );
              },
            )
          : null,
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
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: darkBlue),
                  selectedIcon: Icon(Icons.person, color: darkBlue),
                  label: 'Profile',
                  tooltip: '',
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
