import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/theme_cubit.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/user_entity_extended.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/transcript_dialog.dart';
import '../widgets/grade_calculator_dialog.dart';
import '../../../quiz/presentation/pages/generate_quiz_page.dart';
import '../../../quiz/presentation/pages/multiplayer_lobby_page.dart';
import '../../../quiz/presentation/pages/leaderboard_page.dart';
import '../../../profile/presentation/pages/achievements_page.dart';
import '../../../analytics/presentation/pages/analytics_dashboard_page.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../offline/presentation/pages/offline_management_page.dart';
import '../../../offline/presentation/bloc/offline_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UserBloc>(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _classController;
  late TextEditingController _msvController;
  late TextEditingController _departmentController;
  late TextEditingController _msgvController;

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController();
    _msvController = TextEditingController();
    _departmentController = TextEditingController();
    _msgvController = TextEditingController();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      context.read<UserBloc>().add(LoadUserProfile(authState.user!.id));
    }
  }

  @override
  void dispose() {
    _classController.dispose();
    _msvController.dispose();
    _departmentController.dispose();
    _msgvController.dispose();
    super.dispose();
  }

  void _updateControllers(UserEntityExtended user) {
    if (user.role == 0) {
      _classController.text = user.className ?? '';
      _msvController.text = user.studentId ?? '';
    } else {
      _departmentController.text = user.department ?? '';
      _msgvController.text = user.teacherId ?? '';
    }
  }

  void _onSave(int userId, bool isTeacher, String email, String? fullName) {
    final user = UserEntityExtended(
      id: userId,
      email: email,
      fullName: fullName,
      role: isTeacher ? 1 : 0,
      className: isTeacher ? null : _classController.text,
      studentId: isTeacher ? null : _msvController.text,
      department: isTeacher ? _departmentController.text : null,
      teacherId: isTeacher ? _msgvController.text : null,
    );
    context.read<UserBloc>().add(UpdateUserProfile(user));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : Colors.grey[100];
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final Color inputFillColor = isDarkMode
        ? const Color(0xFF2C2C2C)
        : (Colors.grey[50] ?? Colors.white);
    const accentColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Hồ Sơ Cá Nhân"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : accentColor,
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthInitial) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserProfileLoaded) {
                _updateControllers(state.user);
              } else if (state is UserUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is UserError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess || authState.user == null) {
              return const Center(child: Text("Vui lòng đăng nhập"));
            }

            final authUser = authState.user!;

            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                String name = authUser.fullName ?? "Người dùng";
                String email = authUser.email;
                bool isTeacher = authUser.role == 1;
                String roleName = isTeacher ? "Giáo Viên" : "Sinh Viên";

                if (userState is UserProfileLoaded) {
                  name = userState.user.fullName ?? name;
                  email = userState.user.email;
                  isTeacher = userState.user.role == 1;
                  roleName = isTeacher ? "Giáo Viên" : "Sinh Viên";
                }

                if (userState is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.blue.shade100,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isTeacher ? email : name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (!isTeacher) ...[
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isTeacher
                                    ? Colors.orange.withOpacity(0.2)
                                    : accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                roleName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isTeacher
                                      ? Colors.orange
                                      : accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!isTeacher)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const TranscriptDialog(),
                              );
                            },
                            icon: const Icon(Icons.assessment),
                            label: const Text("Xem Bảng Điểm"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: accentColor),
                              foregroundColor: accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (!isTeacher)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const GradeCalculatorDialog(),
                              );
                            },
                            icon: const Icon(Icons.calculate),
                            label: const Text("Tính Điểm"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.green),
                              foregroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (!isTeacher) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GenerateQuizPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text("Quiz AI"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MultiplayerLobbyPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.people),
                                label: const Text("Multiplayer"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurple,
                                  ),
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final userState = context
                                      .read<UserBloc>()
                                      .state;
                                  if (userState is UserProfileLoaded) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => LeaderboardPage(
                                          classId:
                                              int.tryParse(
                                                userState.user.className ?? '1',
                                              ) ??
                                              1,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đang tải thông tin... Vui lòng thử lại sau giây lát',
                                        ),
                                      ),
                                    );

                                    final authState = context
                                        .read<AuthBloc>()
                                        .state;
                                    if (authState is AuthSuccess &&
                                        authState.user != null) {
                                      context.read<UserBloc>().add(
                                        LoadUserProfile(authState.user!.id),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.leaderboard),
                                label: const Text("Leaderboard"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(color: Colors.orange),
                                  foregroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AchievementsPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.emoji_events),
                            label: const Text("Thành Tích & Streak"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.amber),
                              foregroundColor: Colors.amber[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (_) => di.sl<AnalyticsBloc>(),
                                    child: AnalyticsDashboardPage(
                                      userId: authUser.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bar_chart),
                            label: const Text("Thống kê học tập"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.indigo),
                              foregroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (_) => di.sl<OfflineBloc>(),
                                    child: const OfflineManagementPage(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download_for_offline),
                            label: const Text("Quản lý Offline"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.teal),
                              foregroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      if (isTeacher) ...[
                        _buildEditableRow(
                          icon: Icons.business,
                          label: "Khoa / Bộ môn",
                          controller: _departmentController,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          fillColor: inputFillColor,
                        ),
                        const SizedBox(height: 16),
                        _buildEditableRow(
                          icon: Icons.badge,
                          label: "Mã Giáo Viên (MSGV)",
                          controller: _msgvController,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          fillColor: inputFillColor,
                          isNumber: true,
                        ),
                      ] else ...[
                        _buildEditableRow(
                          icon: Icons.school_outlined,
                          label: "Lớp / Chuyên ngành",
                          controller: _classController,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          fillColor: inputFillColor,
                        ),
                        const SizedBox(height: 16),
                        _buildEditableRow(
                          icon: Icons.badge_outlined,
                          label: "Mã số sinh viên (MSV)",
                          controller: _msvController,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          fillColor: inputFillColor,
                          isNumber: true,
                        ),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () =>
                              _onSave(authUser.id, isTeacher, email, name),
                          child: const Text(
                            "Lưu Thông Tin",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.purple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: isDarkMode ? Colors.orange : Colors.purple,
                            ),
                          ),
                          title: Text(
                            "Chế độ tối",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          value: isDarkMode,
                          activeThumbColor: accentColor,
                          onChanged: (value) {
                            context.read<ThemeCubit>().toggleTheme(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text(
                                "Đăng Xuất",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color cardColor,
    required Color textColor,
    required Color? subTextColor,
    required Color fillColor,
    bool isNumber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: subTextColor),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: isNumber
                      ? TextInputType.number
                      : TextInputType.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    hintText: "Nhập $label",
                    hintStyle: TextStyle(color: subTextColor?.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit, size: 18, color: subTextColor),
        ],
      ),
    );
  }
}
