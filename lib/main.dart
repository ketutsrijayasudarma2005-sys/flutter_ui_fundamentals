import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_state.dart';
import 'models/course.dart';
const String studentName = 'I Ketut Srijaya Sudarma';
const String studentId = '2415051063';
const Color primaryBlue = Color(0xFF1976D2);
const Color darkBlue = Color(0xFF173B63);
const Color backgroundColor = Color(0xFFF1F6FA);
const Color cardColor = Color(0xFFF9FCFF);
const Color navigationColor = Color(0xFFE4F1FC);
const Color borderColor = Color(0xFFC3D8E9);
const Color greenColor = Color(0xFF008F78);

void main() {
  runApp(
    ChangeNotifierProvider<CourseState>(
      create: (_) => CourseState(),
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
          backgroundColor: backgroundColor,
          foregroundColor: darkBlue,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}
// DATA COURSE
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
// MAIN PAGE
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
    // 41. Uji service melalui Provider atau debugPrint sementara
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseState>().loadCourses();
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
    final isExpanded = MediaQuery.sizeOf(context).width >= 840;
    final pages = [
      HomePage(onCourseTap: openDetail),
      CoursesPage(onCourseTap: openDetail),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer'),
        actions: [
          Consumer<CourseState>(
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
                  icon: Icon(Icons.person_outline, color: darkBlue),
                  selectedIcon: Icon(Icons.person, color: darkBlue),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}

// HOME PAGE
class HomePage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;
  const HomePage({
    super.key,
    required this.onCourseTap,
  });


  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Topi Toga (Graduation Cap)
            const Icon(
              Icons.school,
              size: 80,
              color: Color(0xFF232B38),
            ),
            const SizedBox(height: 18),

            // Judul Course Explorer
            const Text(
              'Course Explorer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Deskripsi Aplikasi
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'E-LEARNING.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),

            // Card Identitas Mahasiswa
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Text(
                    'Identitas Mahasiswa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nama: $studentName',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'NIM: $studentId',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Tampilkan Info
            OutlinedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: const [
                          Icon(Icons.info_outline, color: primaryBlue),
                          SizedBox(width: 8),
                          Text('Informasi'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Course Explorer',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Aplikasi pembelajaran Flutter UI Fundamentals.'),
                          const Divider(height: 20),
                          Text('Nama: $studentName'),
                          Text('NIM: $studentId'),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              // Tahap 8: Mengubah satu data JSON menjadi object Course
                              final sampleCourse = Course.fromJson(courses.first);
                              return Text(
                                'Sample Model: ${sampleCourse.title} (${sampleCourse.code})',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              );
                            },
                          ),
                          Consumer<CourseState>(
                            builder: (context, state, _) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('Favorit: ${state.favorites.length} course'),
                              );
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFF475569),
              ),
              label: const Text(
                'Tampilkan Info',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// SUMMARY CARD
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const SummaryCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FC),
        border: Border.all(color: const Color(0xFFAED3E9)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF536D87), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
// COURSES PAGE
class CoursesPage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;
  const CoursesPage({
    super.key,
    required this.onCourseTap,
  });
  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final courseModels = courseState.courses.isNotEmpty
        ? courseState.courses
        : courses.map((json) => Course.fromJson(json)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courseModels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 155,
          ),
          itemBuilder: (context, index) {
            final course = courseModels[index];
            return CourseCard(
              course: course,
              onTap: () => onCourseTap(course),
            );
          },
        );
      },
    );
  }
}
// FAVORITES PAGE
class FavoritesPage extends StatelessWidget {
  final ValueChanged<Course> onCourseTap;
  const FavoritesPage({
    super.key,
    required this.onCourseTap,
  });
  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final courseModels = courseState.courses.isNotEmpty
        ? courseState.courses
        : courses.map((json) => Course.fromJson(json)).toList();
    final favoriteCourses = courseModels
        .where((course) => courseState.isFavorite(course.code))
        .toList();
    if (favoriteCourses.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada course favorit.',
          style: TextStyle(color: darkBlue, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteCourses.length,
      itemBuilder: (context, index) {
        final course = favoriteCourses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CourseCard(
            course: course,
            onTap: () => onCourseTap(course),
            compact: true,
          ),
        );
      },
    );
  }
}
// COURSE CARD
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool compact;
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) {
    final courseCode = course.code;

    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      course.status,
                      style: const TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${course.code} • ${course.credits} SKS',
                        style: const TextStyle(
                          color: Color(0xFF536D87),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 32. Gunakan Consumer pada satu bagian kecil UI
              Consumer<CourseState>(
                builder: (context, state, child) {
                  final isFavorite = state.isFavorite(courseCode);
                  return IconButton(
                    tooltip: isFavorite
                        ? 'Hapus dari favorit'
                        : 'Tambah ke favorit',
                    // 31. Gunakan read() pada tombol toggle favorite
                    onPressed: () {
                      context.read<CourseState>().toggleFavorite(courseCode);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? greenColor : darkBlue,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// COURSE DETAIL PAGE
class CourseDetailPage extends StatelessWidget {
  final Course course;
  const CourseDetailPage({
    super.key,
    required this.course,
  });
  @override
  Widget build(BuildContext context) {
    final courseCode = course.code;

    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            '$studentId • $studentName',
            textAlign: TextAlign.center,
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Kode: ${course.code}'),
                const SizedBox(height: 10),
                Text('SKS: ${course.credits}'),
                const SizedBox(height: 10),
                Text('Status: ${course.status}'),
                const SizedBox(height: 10),
                Text('Kategori: ${course.category}'),
                const SizedBox(height: 20),
                // 32. Gunakan Consumer pada satu bagian kecil UI
                Consumer<CourseState>(
                  builder: (context, state, child) {
                    final isFavorite = state.isFavorite(courseCode);
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        // 31. Gunakan read() pada tombol toggle favorite
                        onPressed: () {
                          context.read<CourseState>().toggleFavorite(courseCode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? 'Course dihapus dari favorit'
                                    : 'Course ditambahkan ke favorit',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Hapus dari Favorites'
                              : 'Tambah ke Favorites',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// PROFILE + FORM
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nimController = TextEditingController();
  final commentController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    commentController.dispose();
    super.dispose();
  }
  void submitFeedback() {
    if (formKey.currentState!.validate()) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Feedback berhasil dikirim.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.account_circle, size: 100, color: primaryBlue),
          const SizedBox(height: 10),
          const Text(
            '$studentId - $studentName',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 30),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nimController,
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIM wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Komentar',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Komentar minimal 5 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitFeedback,
                    child: const Text('Kirim Feedback'),
                  ),
                ),
              ],
            ),
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

