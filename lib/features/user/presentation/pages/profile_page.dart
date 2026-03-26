import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common/theme_cubit.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/user_entity_extended.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/grade_calculator_dialog.dart';
import '../widgets/change_password_dialog.dart';

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

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _classController;
  late TextEditingController _msvController;
  late TextEditingController _departmentController;
  late TextEditingController _msgvController;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController();
    _msvController = TextEditingController();
    _departmentController = TextEditingController();
    _msgvController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

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
    _animController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = AppColors.cardColor(context);
    final textColor = AppColors.textPrimary(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthInitial) {
                context.go(AppRoutes.login);
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
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (state is UserError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess || authState.user == null) {
              return const Center(child: Text('Vui lòng đăng nhập'));
            }

            final authUser = authState.user!;

            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                String name = authUser.fullName ?? 'Người dùng';
                String email = authUser.email;
                bool isTeacher = authUser.role == 1;
                String roleName = isTeacher ? 'Giảng Viên' : 'Sinh Viên';

                if (userState is UserProfileLoaded) {
                  name = userState.user.fullName ?? name;
                  email = userState.user.email;
                  isTeacher = userState.user.role == 1;
                  roleName = isTeacher ? 'Giảng Viên' : 'Sinh Viên';
                }

                if (userState is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomScrollView(
                  slivers: [
                    _buildHeroHeader(
                      name: name,
                      email: email,
                      isTeacher: isTeacher,
                      roleName: roleName,
                      theme: theme,
                      isDark: isDark,
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),



                            _buildInfoSection(
                              isTeacher: isTeacher,
                              userState: userState,
                              theme: theme,
                              cardColor: cardColor,
                              textColor: textColor,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),

                            if (!isTeacher) ...[
                              _buildSectionCard(
                                title: 'Công cụ học tập',
                                icon: Icons.school_outlined,
                                theme: theme,
                                cardColor: cardColor,
                                textColor: textColor,
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.calculate,
                                    label: 'Tính Điểm',
                                    color: AppColors.success,
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (_) =>
                                          const GradeCalculatorDialog(),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            _buildSectionCard(
                              title: 'Cài đặt',
                              icon: Icons.settings_outlined,
                              theme: theme,
                              cardColor: cardColor,
                              textColor: textColor,
                              children: [
                                SwitchListTile(
                                  secondary: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          (isDark
                                                  ? AppColors.warning
                                                  : AppColors.secondary)
                                              .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isDark
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      color: isDark
                                          ? AppColors.warning
                                          : AppColors.secondary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    'Chế độ tối',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  value: isDark,
                                  onChanged: (value) {
                                    context.read<ThemeCubit>().toggleTheme(
                                      value,
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.lock_reset_rounded,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    'Đổi Mật Khẩu',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  trailing: Icon(Icons.chevron_right, size: 20),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          const ChangePasswordDialog(),
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: BorderSide(
                                    color: AppColors.error.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    LogoutRequested(),
                                  );
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                  'Đăng Xuất',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader({
    required String name,
    required String email,
    required bool isTeacher,
    required String roleName,
    required ThemeData theme,
    required bool isDark,
  }) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.primaryDark.withValues(alpha: 0.4),
                  ]
                : [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.secondary,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTeacher ? Icons.workspace_premium : Icons.school,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    roleName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInfoSection({
    required bool isTeacher,
    required UserState userState,
    required ThemeData theme,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Thông tin cá nhân',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          if (isTeacher) ...[
            _buildInfoField(
              label: 'Khoa / Bộ môn',
              controller: _departmentController,
              icon: Icons.business,
              editable: false,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              label: 'Mã số giảng viên',
              controller: _msgvController,
              icon: Icons.badge,
              editable: false,
              isDark: isDark,
            ),
          ] else ...[
            _buildInfoField(
              label: 'Lớp',
              controller: _classController,
              icon: Icons.class_,
              editable: false,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              label: 'Mã sinh viên',
              controller: _msvController,
              icon: Icons.badge,
              editable: false,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool editable,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: editable
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                editable
                    ? TextField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        controller.text.isEmpty
                            ? 'Chưa cập nhật'
                            : controller.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: controller.text.isEmpty
                              ? (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                          fontStyle: controller.text.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required Color cardColor,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.textSecondary(context),
      ),
      onTap: onTap,
    );
  }
}
