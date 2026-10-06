import 'package:flutter/material.dart';

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
  runApp(const MyApp());
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
            fontSize: 22,
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

  // Favorite disimpan terpusat agar bisa digunakan bersama.
  final Set<String> favoriteCodes = {'MOB01', 'MOB02'};

  void toggleFavorite(String code) {
    setState(() {
      if (favoriteCodes.contains(code)) {
        favoriteCodes.remove(code);
      } else {
        favoriteCodes.add(code);
      }
    });
  }

  void openDetail(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(
          course: course,
          isFavorite: favoriteCodes.contains(course['code']),
          onFavoriteTap: () => toggleFavorite(course['code']),
        ),
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
      HomePage(
        favoriteCount: favoriteCodes.length,
        favoriteCodes: favoriteCodes,
        onCourseTap: openDetail,
        onFavoriteTap: toggleFavorite,
      ),
      CoursesPage(
        favoriteCodes: favoriteCodes,
        onCourseTap: openDetail,
        onFavoriteTap: toggleFavorite,
      ),
      FavoritesPage(
        favoriteCodes: favoriteCodes,
        onCourseTap: openDetail,
        onFavoriteTap: toggleFavorite,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer v2'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: openProfile,
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '$studentId • $studentName',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
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
                          icon: Icon(Icons.favorite_border),
                          selectedIcon: Icon(Icons.favorite),
                          label: Text('Favorites'),
                        ),
                      ],
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
                  icon: Icon(Icons.favorite_border, color: darkBlue),
                  selectedIcon: Icon(Icons.favorite, color: darkBlue),
                  label: 'Favorites',
                ),
              ],
            ),
    );
  }
}

// HOME PAGE

class HomePage extends StatelessWidget {
  final int favoriteCount;
  final Set<String> favoriteCodes;
  final ValueChanged<Map<String, dynamic>> onCourseTap;
  final ValueChanged<String> onFavoriteTap;

  const HomePage({
    super.key,
    required this.favoriteCount,
    required this.favoriteCodes,
    required this.onCourseTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(title: 'Courses', value: '${courses.length}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(title: 'Favorites', value: '$favoriteCount'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...courses
            .take(3)
            .map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CourseCard(
                  course: course,
                  isFavorite: favoriteCodes.contains(course['code']),
                  onTap: () => onCourseTap(course),
                  onFavoriteTap: () => onFavoriteTap(course['code']),
                  compact: true,
                ),
              ),
            ),
      ],
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
  final Set<String> favoriteCodes;
  final ValueChanged<Map<String, dynamic>> onCourseTap;
  final ValueChanged<String> onFavoriteTap;

  const CoursesPage({
    super.key,
    required this.favoriteCodes,
    required this.onCourseTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 155,
          ),
          itemBuilder: (context, index) {
            final course = courses[index];

            return CourseCard(
              course: course,
              isFavorite: favoriteCodes.contains(course['code']),
              onTap: () => onCourseTap(course),
              onFavoriteTap: () => onFavoriteTap(course['code']),
            );
          },
        );
      },
    );
  }
}

// FAVORITES PAGE

class FavoritesPage extends StatelessWidget {
  final Set<String> favoriteCodes;
  final ValueChanged<Map<String, dynamic>> onCourseTap;
  final ValueChanged<String> onFavoriteTap;

  const FavoritesPage({
    super.key,
    required this.favoriteCodes,
    required this.onCourseTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteCourses = courses
        .where((course) => favoriteCodes.contains(course['code']))
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
            isFavorite: true,
            onTap: () => onCourseTap(course),
            onFavoriteTap: () => onFavoriteTap(course['code']),
            compact: true,
          ),
        );
      },
    );
  }
}

// COURSE CARD

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool compact;

  const CourseCard({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
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
                      course['title'] as String,
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
                      course['status'] as String,
                      style: const TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${course['code']} • ${course['credits']} SKS',
                        style: const TextStyle(
                          color: Color(0xFF536D87),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambah ke favorit',
                onPressed: onFavoriteTap,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? greenColor : darkBlue,
                ),
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
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  course['title'] as String,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Kode: ${course['code']}'),
                const SizedBox(height: 10),
                Text('SKS: ${course['credits']}'),
                const SizedBox(height: 10),
                Text('Status: ${course['status']}'),
                const SizedBox(height: 10),
                Text('Kategori: ${course['category']}'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onFavoriteTap();
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
