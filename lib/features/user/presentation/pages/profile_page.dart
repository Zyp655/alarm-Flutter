import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/theme_cubit.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _classController;
  late TextEditingController _msvController;

  late TextEditingController _departmentController;
  late TextEditingController _msgvController;

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController(text: "");
    _msvController = TextEditingController(text: "");

    _departmentController = TextEditingController(text: "");
    _msgvController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _classController.dispose();
    _msvController.dispose();
    _departmentController.dispose();
    _msgvController.dispose();
    super.dispose();
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          }
        },
        builder: (context, state) {
          String name = "Người dùng";
          String email = "user@email.com";
          String roleName = "Sinh Viên";
          bool isTeacher = false;

          if (state is AuthSuccess && state.user != null) {
            name = state.user!.fullName ?? "Chưa cập nhật tên";
            email = state.user!.email;

            isTeacher = state.user!.role == 1;
            roleName = isTeacher ? "Giáo Viên" : "Sinh Viên";
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
                          border: Border.all(color: accentColor, width: 2),
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
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: subTextColor),
                      ),
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
                            color: isTeacher ? Colors.orange : accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                    onPressed: () {
                      final info = isTeacher
                          ? "Khoa: ${_departmentController.text}, MSGV: ${_msgvController.text}"
                          : "Lớp: ${_classController.text}, MSV: ${_msvController.text}";

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Đã lưu thông tin $roleName:\n$info"),
                        ),
                      );
                    },
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
