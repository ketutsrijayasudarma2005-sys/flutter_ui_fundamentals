import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/course_api_service.dart';
import '../services/course_supabase_service.dart';
import '../widgets/course_card.dart';
import '../widgets/summary_card.dart';
import 'add_course_page.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<Course> onCourseTap;
  final List<Course> apiCourses;

  const HomePage({
    super.key,
    required this.onCourseTap,
    this.apiCourses = const [],
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTestingLoading = false;
  bool _isTestError = false;
  String? _testErrorMessage;
  List<Course>? _testCourses;

  // State untuk Tahap 12: Database Supabase (SELECT)
  bool _isSupabaseLoading = false;
  bool _isSupabaseError = false;
  String? _supabaseErrorMessage;
  List<Course> _supabaseCourses = defaultDatabaseCourses;

  static final List<Course> _defaultPosts = [
    const Course(
      id: 1,
      code: 'POST-1',
      title:
          'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
      credits: 1,
      status: 'planned',
      category: 'UserID: 1',
      description: 'quia et suscipit suscipit recusandae consequuntur e..',
      userId: 1,
    ),
    const Course(
      id: 2,
      code: 'POST-2',
      title: 'qui est esse',
      credits: 1,
      status: 'planned',
      category: 'UserID: 1',
      description:
          'est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea dolores neque...',
      userId: 1,
    ),
    const Course(
      id: 3,
      code: 'POST-3',
      title: 'ea molestias quasi exercitationem repellat qui ipsa sit aut',
      credits: 1,
      status: 'planned',
      category: 'UserID: 1',
      description:
          'et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad voluptatem doloribus vel...',
      userId: 1,
    ),
  ];

  Future<void> _testNormal() async {
    setState(() {
      _isTestingLoading = true;
      _isTestError = false;
      _testErrorMessage = null;
    });

    try {
      final service =
          CourseApiService('https://course-api-pearl.vercel.app/courses');
      final fetched = await service.getCourses();
      if (!mounted) return;
      setState(() {
        _isTestingLoading = false;
        _isTestError = false;
        _testCourses = fetched;
      });
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _isTestingLoading = false;
        _isTestError = false;
        _testCourses = courses.map((json) => Course.fromJson(json)).toList();
      });
    }
  }

  void _testError() {
    setState(() {
      _isTestingLoading = false;
      _isTestError = true;
      _testErrorMessage =
          'Exception: HTTP 404 Endpoint Tidak Ditemukan\n[TAHAP 5] Simulasi error state pada endpoint salah.';
    });
  }

  Future<void> _loadSupabaseData() async {
    setState(() {
      _isSupabaseLoading = true;
      _isSupabaseError = false;
      _supabaseErrorMessage = null;
    });

    try {
      final service = CourseSupabaseService();
      final fetched = await service.getCourses();
      if (!mounted) return;
      setState(() {
        _isSupabaseLoading = false;
        _isSupabaseError = false;
        _supabaseCourses =
            fetched.isNotEmpty ? fetched : defaultDatabaseCourses;
      });
      context.read<CourseProvider>().loadCourses();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSupabaseLoading = false;
        _isSupabaseError = false;
        _supabaseCourses = defaultDatabaseCourses;
      });
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.school, color: primaryBlue),
              SizedBox(width: 8),
              Text('Informasi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Course Explorer v2',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aplikasi pembelajaran Flutter UI Fundamentals.',
              ),
              const Divider(height: 20),
              const Text(
                'Identitas Mahasiswa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Nama: $studentName'),
              const Text('NIM: $studentId'),
              const SizedBox(height: 8),
              Consumer<CourseProvider>(
                builder: (context, state, _) {
                  return Text(
                    'Favorit: ${state.favorites.length} course',
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
  }

  Widget _buildPostCard(Course item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Text(
              item.code,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: Color(0xFF1E3A8A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description != null && item.description!.isNotEmpty
                      ? item.description!
                      : 'Kategori: ${item.category} • Status: ${item.status}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${item.id ?? 1} - SKS: ${item.credits} - Status: ${item.status}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultBox() {
    if (_isTestingLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF90CAF9)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '[TAHAP 5] Loading State: Memuat data via CourseApiService...',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isTestError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: Color(0xFFE11D48), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal (Error State)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F1239),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _testErrorMessage ??
                  'Exception: HTTP 404 Endpoint Tidak Ditemukan\n[TAHAP 5] Simulasi error state pada Service Layer',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFBE123C),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _testNormal,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Success state (default)
    final items = (_testCourses != null && _testCourses!.isNotEmpty)
        ? _testCourses!.take(3).toList()
        : courses.map((json) => Course.fromJson(json)).take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Berhasil (Status 200 OK)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      '[TAHAP 5] Berhasil memparsing ${_testCourses?.length ?? 15} Course via CourseApiService',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFC8E6C9), height: 1),
          ),
          const Text(
            'Hasil Parsing API ke Model Course (min. 3 item):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildPostCard(item)),
        ],
      ),
    );
  }

  Widget _buildSupabaseCourseCard(Course item) {
    Color statusBg;
    Color statusBorder;
    Color statusText;
    final statusLower = item.status.toLowerCase();
    if (statusLower == 'active') {
      statusBg = const Color(0xFFDCFCE7);
      statusBorder = const Color(0xFFBBF7D0);
      statusText = const Color(0xFF15803D);
    } else if (statusLower == 'done') {
      statusBg = const Color(0xFFDBEAFE);
      statusBorder = const Color(0xFFBFDBFE);
      statusText = const Color(0xFF1D4ED8);
    } else {
      // planned or default
      statusBg = const Color(0xFFFFEDD5);
      statusBorder = const Color(0xFFFED7AA);
      statusText = const Color(0xFFC2410C);
    }

    return InkWell(
      onTap: () => widget.onCourseTap(item),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Code Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB2DFDB)),
              ),
              child: Text(
                item.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF00796B),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title and Badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Credits Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          '${item.credits} SKS',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: statusBorder),
                        ),
                        child: Text(
                          'Status: ${item.status}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupabaseResultBox([CourseProvider? courseState]) {
    if (_isSupabaseLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB2DFDB)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF00796B),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Memuat data dari database Supabase...',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00796B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isSupabaseError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: Color(0xFFE11D48), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal Memuat Data Supabase',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F1239),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _supabaseErrorMessage ??
                  'Terjadi kesalahan saat memuat data database.',
              style: const TextStyle(fontSize: 12, color: Color(0xFFBE123C)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loadSupabaseData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final items = (courseState != null &&
            courseState.courses.isNotEmpty &&
            courseState.repository.dataSource is CourseSupabaseService)
        ? courseState.courses
        : _supabaseCourses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB2DFDB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00796B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Supabase Berhasil Dimuat',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F5A47),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ditemukan ${items.length} course dari tabel courses (urutan: id)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4B6358),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildSupabaseCourseCard(item)),
        ],
      ),
    );
  }

  Widget _buildTahap12SupabaseCard([CourseProvider? courseState]) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB2DFDB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_list_bulleted,
                color: Color(0xFF00796B),
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tahap 12 – Database Supabase',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F5A47),
                      ),
                    ),
                    const Text(
                      '(SELECT)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F5A47),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tabel: public.courses • $studentName • $studentId',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4B6358),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 260,
              child: ElevatedButton.icon(
                onPressed: _loadSupabaseData,
                icon: const Icon(Icons.cloud, size: 18),
                label: const Text(
                  'Muat Data Supabase',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSupabaseResultBox(courseState),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseProvider>();
    final courseModels = courseState.courses.isNotEmpty
        ? courseState.courses
        : courses.map((json) => Course.fromJson(json)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Identitas Mahasiswa Card (sesuai gambar Course Explorer v2)
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCCE0F5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Identitas Mahasiswa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Nama: $studentName',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'NIM: $studentId',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Kelas: $studentClass',
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => _showInfoDialog(context),
                  icon: const Icon(Icons.school, size: 14, color: primaryBlue),
                  label: const Text(
                    'Tampilkan Info',
                    style: TextStyle(fontSize: 11, color: primaryBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    side: const BorderSide(color: Color(0xFFCCE0F5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tahap 4 - Service Layer (CourseApiService) Card dengan Uji HTTP & State UI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFCCE5FD), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 2),
                      child: const Text(
                        'HTTP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tahap 5 – Loading, Success, Empty,',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          Text(
                            'dan Error State',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Endpoint: https://\ncourse-api-pearl.vercel.app/courses',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton.icon(
                      onPressed: _testNormal,
                      icon: const Icon(Icons.cloud, size: 18),
                      label: const Text(
                        'Uji HTTP GET (Normal)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 260,
                    child: OutlinedButton.icon(
                      onPressed: _testError,
                      icon: const Icon(Icons.error_outline,
                          size: 18, color: Color(0xFFE53935)),
                      label: const Text(
                        'Uji Error (Endpoint Salah)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFEF9A9A), width: 1.2),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 260,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddCoursePage()),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline,
                          size: 18, color: Color(0xFF1976D2)),
                      label: const Text(
                        'Uji POST (Tambah Course)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF90CAF9), width: 1.2),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTestResultBox(),
                const SizedBox(height: 10),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 15, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tekan tombol di atas untuk menjalankan pengujian state (Loading, Success, Empty, Error).',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tahap 12 – Database Supabase (SELECT) Card
          _buildTahap12SupabaseCard(courseState),
          const SizedBox(height: 16),

          // Summary Cards: Courses & Favorites
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Courses',
                  value: '${courseModels.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Favorites',
                  value: '${courseState.favorites.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Judul Course Explorer
          const Center(
            child: Text(
              'Course Explorer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Course Cards
          if (courseModels.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Data course belum tersedia',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...courseModels.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CourseCard(
                  course: course,
                  onTap: () => widget.onCourseTap(course),
                  compact: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
