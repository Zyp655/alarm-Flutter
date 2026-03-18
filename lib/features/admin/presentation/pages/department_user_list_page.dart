import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../../injection_container.dart';
import '../widgets/department_card.dart';
import '../widgets/soft_user_tile.dart';

class DepartmentUserListArgs {
  final int role;
  final String roleLabel;
  final Color accentColor;
  final IconData roleIcon;

  const DepartmentUserListArgs({
    required this.role,
    required this.roleLabel,
    required this.accentColor,
    required this.roleIcon,
  });
}

class DepartmentUserListPage extends StatefulWidget {
  final DepartmentUserListArgs args;
  const DepartmentUserListPage({super.key, required this.args});

  @override
  State<DepartmentUserListPage> createState() => _DepartmentUserListPageState();
}

class _DepartmentUserListPageState extends State<DepartmentUserListPage> {
  final AdminRepository _repo = sl<AdminRepository>();
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  int? _selectedDeptId;
  String? _selectedDeptName;
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingUsers = false;
  String _searchQuery = '';

  static const int _pageSize = 50;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _totalUsers = 0;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMore();
      });
    }
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoading = true);
    final result = await _repo.getAcademicData();
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      (data) {
        setState(() {
          _departments = List<Map<String, dynamic>>.from(
            data['departments'] ?? [],
          );
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadUsers(int departmentId, {bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _users = [];
        _isLoadingUsers = true;
      });
    } else {
      setState(() => _isLoadingUsers = true);
    }

    final result = await _repo.getUsers(
      role: widget.args.role,
      departmentId: departmentId,
      page: 1,
      limit: _pageSize,
    );
    result.fold(
      (failure) {
        setState(() => _isLoadingUsers = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      (data) {
        final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        final pagination = data['pagination'] as Map<String, dynamic>?;
        setState(() {
          _users = users;
          _currentPage = 1;
          _totalUsers = pagination?['total'] ?? users.length;
          _hasMore = pagination?['hasMore'] ?? false;
          _isLoadingUsers = false;
        });
      },
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _selectedDeptId == null) return;
    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final result = await _repo.getUsers(
      role: widget.args.role,
      departmentId: _selectedDeptId,
      page: nextPage,
      limit: _pageSize,
    );
    result.fold(
      (failure) {
        setState(() => _isLoadingMore = false);
      },
      (data) {
        final newUsers = List<Map<String, dynamic>>.from(data['users'] ?? []);
        final pagination = data['pagination'] as Map<String, dynamic>?;
        setState(() {
          _users.addAll(newUsers);
          _currentPage = nextPage;
          _hasMore = pagination?['hasMore'] ?? false;
          _isLoadingMore = false;
        });
      },
    );
  }

  void _selectDepartment(int id, String name) {
    setState(() {
      _selectedDeptId = id;
      _selectedDeptName = name;
      _searchQuery = '';
    });
    _loadUsers(id);
  }

  void _backToDepartments() {
    setState(() {
      _selectedDeptId = null;
      _selectedDeptName = null;
      _users = [];
      _currentPage = 1;
      _hasMore = true;
      _totalUsers = 0;
    });
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users
        .where(
          (u) =>
              (u['fullName'] as String? ?? '').toLowerCase().contains(q) ||
              (u['email'] as String? ?? '').toLowerCase().contains(q) ||
              (u['studentId'] as String? ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.args.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_selectedDeptId != null) {
              _backToDepartments();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.args.roleLabel,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3436),
              ),
            ),
            if (_selectedDeptName != null)
              Text(
                '$_selectedDeptName ($_totalUsers)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
          ],
        ),
        bottom: _selectedDeptId != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, email...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFFB0BEC5),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedDeptId == null
          ? _buildDepartmentGrid(accent)
          : _buildUserList(accent),
    );
  }

  Widget _buildDepartmentGrid(Color accent) {
    if (_departments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.apartment_rounded, size: 36, color: accent),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có khoa nào',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tạo khoa trong tab Học Thuật trước',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDepartments,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemCount: _departments.length,
        itemBuilder: (_, i) {
          final dept = _departments[i];
          final name = dept['name'] as String? ?? 'Khoa';
          final id = dept['id'] as int;
          return DepartmentCard(
            name: name,
            accentColor: accent,
            onTap: () => _selectDepartment(id, name),
          );
        },
      ),
    );
  }

  Widget _buildUserList(Color accent) {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = _filteredUsers;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.args.roleIcon,
                size: 36,
                color: const Color(0xFFB0BEC5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Không tìm thấy kết quả'
                  : 'Chưa có ${widget.args.roleLabel.toLowerCase()} nào',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Thử từ khoá khác'
                  : 'Import từ Excel để thêm dữ liệu',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      );
    }

    final itemCount = users.length + (_hasMore && _searchQuery.isEmpty ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => _loadUsers(_selectedDeptId!, refresh: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: itemCount,
        itemBuilder: (_, i) {
          if (i >= users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return SoftUserTile(
            user: users[i],
            accent: accent,
            roleIcon: widget.args.roleIcon,
          );
        },
      ),
    );
  }
}
