import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../core/api/api_constants.dart';

import '../widgets/custom_search_bar.dart';
import '../widgets/filter_chip_group.dart';
import '../widgets/notification_dialog_widget.dart';
import 'teacher_students/widgets/students_stats_overview.dart';
import 'teacher_students/widgets/student_progress_card.dart';
import 'teacher_students/widgets/student_detail_sheet.dart';
import 'teacher_students/widgets/insights_tab.dart';

class TeacherStudentsPage extends StatefulWidget {
  final int teacherId;
  final int? initialCourseId;

  const TeacherStudentsPage({
    super.key,
    required this.teacherId,
    this.initialCourseId,
  });

  @override
  State<TeacherStudentsPage> createState() => _TeacherStudentsPageState();
}

class _TeacherStudentsPageState extends State<TeacherStudentsPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _courses = [];
  List<dynamic> _students = [];
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _insightsData;

  int? _selectedCourseId;
  String? _selectedStatus;
  String? _selectedProgress;
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  String _searchQuery = '';
  int _riskThreshold = 3;

  bool _isLoading = true;
  bool _isLoadingInsights = false;
  bool _isMultiSelectMode = false;
  late TabController _tabController;
  Set<int> _selectedStudentIds = {};
  final _searchController = TextEditingController();

  static const primaryOrange = Color(0xFFFF6636);
  static const darkBg = Color(0xFF0F172A);
  static const cardBg = Color(0xFF1E293B);
  static const inputBg = Color(0xFF334155);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCourseId = widget.initialCourseId;
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final courses = (data['courses'] as List).cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            _courses = courses
                .where((c) => c['instructorId'] == widget.teacherId)
                .toList();
            if (_selectedCourseId != null) {
              _loadStudents();
              _loadInsights();
            } else if (_courses.isNotEmpty) {
              _selectedCourseId = _courses.first['id'];
              _loadStudents();
              _loadInsights();
            } else {
              _isLoading = false;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedCourseId == null) return;

    setState(() => _isLoading = true);

    try {
      final queryParams = <String, String>{};
      if (_selectedStatus != null) queryParams['status'] = _selectedStatus!;
      if (_selectedProgress != null)
        queryParams['progress'] = _selectedProgress!;
      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
      queryParams['sortBy'] = _sortBy;
      queryParams['sortOrder'] = _sortOrder;
      queryParams['threshold'] = _riskThreshold.toString();

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/courses/$_selectedCourseId/students',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _students = data['students'] ?? [];
            _stats = data['stats'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInsights() async {
    if (_selectedCourseId == null) return;
    setState(() => _isLoadingInsights = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/courses/$_selectedCourseId/analytics/insights',
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _insightsData = jsonDecode(response.body);
            _isLoadingInsights = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingInsights = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingInsights = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: _isMultiSelectMode
            ? Text('Đã chọn: ${_selectedStudentIds.length}')
            : const Text(
                'Quản lý Sinh viên',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryOrange,
          indicatorWeight: 3,
          labelColor: primaryOrange,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(text: 'Danh sách', icon: Icon(Icons.list_alt_rounded)),
            Tab(text: 'Insights', icon: Icon(Icons.insights_rounded)),
          ],
        ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _isMultiSelectMode = false;
                _selectedStudentIds.clear();
              }),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showConfigDialog,
              tooltip: 'Cấu hình cảnh báo',
            ),
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: _exportData,
              tooltip: 'Xuất dữ liệu',
            ),
          ],
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              if (_stats != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: StudentsStatsOverview(
                    totalStudents: _stats!['totalStudents'] ?? 0,
                    atRiskCount: _stats!['atRiskCount'] ?? 0,
                    averageScore: (_stats!['avgProgress'] ?? 0).toDouble(),
                    activeCount: _stats!['byStatus'] != null
                        ? (_stats!['byStatus']['in_progress'] ?? 0)
                        : 0,
                  ),
                ),
              _buildFilters(),
              Expanded(child: _buildStudentList()),
            ],
          ),

          InsightsTab(
            isLoading: _isLoadingInsights,
            insightsData: _insightsData,
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode && _selectedStudentIds.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: primaryOrange,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text(
                'Gửi thông báo',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _sendBatchNotification,
            )
          : null,
    );
  }

  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text(
          'Cấu hình cảnh báo',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ngưỡng cảnh báo vắng mặt:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _riskThreshold,
              dropdownColor: inputBg,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 3, child: Text('> 3 ngày (Mặc định)')),
                DropdownMenuItem(value: 5, child: Text('> 5 ngày')),
                DropdownMenuItem(value: 7, child: Text('> 7 ngày')),
                DropdownMenuItem(value: 14, child: Text('> 14 ngày')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _riskThreshold = value);
                  Navigator.pop(context);
                  _loadStudents();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Tìm kiếm theo tên, email...',
            onChanged: (value) {},
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              _loadStudents();
            },
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: _selectedCourseId,
                  dropdownColor: inputBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Khóa học',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _courses.map<DropdownMenuItem<int>>((course) {
                    return DropdownMenuItem(
                      value: course['id'] as int,
                      child: Text(
                        course['title'] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCourseId = value);
                    _loadStudents();
                    _loadInsights();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  dropdownColor: inputBg,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Sắp xếp',
                    labelStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Tên', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'progress',
                      child: Text('Tiến độ', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'quizScore',
                      child: Text('Điểm', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'risk',
                      child: Text('Ưu tiên', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _sortBy = value!);
                    _loadStudents();
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _sortOrder == 'asc'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: primaryOrange,
                ),
                onPressed: () {
                  setState(
                    () => _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc',
                  );
                  _loadStudents();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          FilterChipGroup<String?>(
            options: [
              FilterOption(label: 'Tất cả', value: null),
              FilterOption(label: '⚠️ Cần chú ý', value: 'at_risk'),
              FilterOption(label: '⏳ Chưa học', value: 'not_started'),
              FilterOption(label: '📖 Đang học', value: 'in_progress'),
              FilterOption(label: '✅ Hoàn thành', value: 'completed'),
            ],
            selectedValue: _selectedStatus,
            onSelected: (value) {
              setState(() => _selectedStatus = value);
              _loadStudents();
            },
          ),
          const SizedBox(height: 8),

          FilterChipGroup<String?>(
            options: [
              FilterOption(label: 'Tất cả', value: null),
              FilterOption(label: '0-30%', value: 'low'),
              FilterOption(label: '31-70%', value: 'medium'),
              FilterOption(label: '71-100%', value: 'high'),
            ],
            selectedValue: _selectedProgress,
            onSelected: (value) {
              setState(() => _selectedProgress = value);
              _loadStudents();
            },
            selectedColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      );
    }

    if (_courses.isEmpty) {
      return _buildEmptyState(
        Icons.school_outlined,
        'Bạn chưa có khóa học nào',
      );
    }

    if (_students.isEmpty) {
      return _buildEmptyState(Icons.people_outline, 'Chưa có sinh viên nào');
    }

    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: _loadStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          final userId = student['userId'] as int;
          return StudentProgressCard(
            student: student,
            isSelected: _selectedStudentIds.contains(userId),
            isSelectionMode: _isMultiSelectMode,
            onTap: () => _showStudentDetails(student),
            onSelectChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedStudentIds.add(userId);
                } else {
                  _selectedStudentIds.remove(userId);
                  if (_selectedStudentIds.isEmpty) _isMultiSelectMode = false;
                }
              });
            },
            onNudge: () => _showAINudgeDialog(student),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(dynamic student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StudentDetailSheet(
        student: student,
        formatTime: _formatTime,
        onSendNotification: () => _sendNotificationToStudent(student),
        onViewHistory: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang tải lịch sử hoạt động...')),
          );
        },
      ),
    );
  }

  void _showAINudgeDialog(dynamic student) async {
    final userId = student['userId'];
    final name = student['fullName'] ?? 'bạn';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
              SizedBox(height: 16),
              Text(
                'AI đang soạn tin nhắn...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/courses/$_selectedCourseId/students/nudge',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = data['message'] as String;

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => NotificationDialogWidget(
              studentNames: [name],
              initialMessage: aiMessage,
              isAiGenerated: true,
              onSend: (title, message) async {
                await http.put(
                  Uri.parse(
                    '${ApiConstants.baseUrl}/courses/$_selectedCourseId/students/nudge',
                  ),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'userId': userId}),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã gửi nhắc nhở AI thành công!'),
                      backgroundColor: Color(0xFF6C63FF),
                    ),
                  );
                  _loadStudents();
                }
              },
            ),
          );
        }
      } else {
        throw Exception('Failed to generate nudge');
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _sendNotificationToStudent(dynamic student) {
    showDialog(
      context: context,
      builder: (_) => NotificationDialogWidget(
        studentNames: [student['fullName'] ?? 'Unknown'],
        onSend: (title, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã gửi thông báo cho ${student['fullName']}'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _sendBatchNotification() {
    final selectedNames = _students
        .where((s) => _selectedStudentIds.contains(s['userId']))
        .map((s) => s['fullName'] as String? ?? 'Unknown')
        .toList();

    showDialog(
      context: context,
      builder: (_) => NotificationDialogWidget(
        studentNames: selectedNames,
        onSend: (title, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã gửi thông báo cho ${_selectedStudentIds.length} sinh viên',
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isMultiSelectMode = false;
            _selectedStudentIds.clear();
          });
        },
      ),
    );
  }

  void _exportData() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Xuất dữ liệu sinh viên',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text(
                'Xuất Excel (.xlsx)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xuất file Excel...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text(
                'Xuất CSV (.csv)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xuất file CSV...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}
