//Nama : I Ketut Srijaya Sudarma
//NIM : 2415051063

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'add_course_page.dart';
import 'course_detail_page.dart';
import 'course_list_page.dart';
import 'courses_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class ResponsiveShell extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<Course>? onCourseTap;

  const ResponsiveShell({
    super.key,
    this.initialIndex = 0,
    this.onCourseTap,
  });

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  void openDetail(Course course) {
    if (widget.onCourseTap != null) {
      widget.onCourseTap!(course);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailPage(course: course),
        ),
      );
    }
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
      CourseListPage(onCourseTap: openDetail),
      CoursesPage(onCourseTap: openDetail),
      FavoritesPage(onCourseTap: openDetail),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndex == 1
              ? 'Course Data Manager'
              : 'Course Explorer v2',
        ),
        actions: [
          IconButton(
            tooltip: 'Course Data Manager',
            icon: const Icon(Icons.dataset_outlined),
            onPressed: () {
              setState(() {
                selectedIndex = 1;
              });
            },
          ),
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
                    icon: Icon(Icons.dataset_outlined),
                    selectedIcon: Icon(Icons.dataset),
                    label: Text('Manager'),
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
      floatingActionButton: (selectedIndex == 1 || selectedIndex == 2)
          ? FloatingActionButton.extended(
              heroTag: 'shell_add_course_fab',
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
                  icon: Icon(Icons.dataset_outlined, color: darkBlue),
                  selectedIcon: Icon(Icons.dataset, color: darkBlue),
                  label: 'Manager',
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

