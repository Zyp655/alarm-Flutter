import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 0;
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _errorText;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorText = 'Vui lòng nhập email hợp lệ');
      return;
    }
    setState(() => _errorText = null);
    context.read<AuthBloc>().add(ForgotPasswordRequested(email: email));
  }

  void _resetPassword() {
    final otp = _otpCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (otp.length != 6) {
      setState(() => _errorText = 'Mã OTP phải có 6 chữ số');
      return;
    }
    if (pass.length < 6) {
      setState(() => _errorText = 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }
    if (pass != confirm) {
      setState(() => _errorText = 'Mật khẩu xác nhận không khớp');
      return;
    }
    setState(() => _errorText = null);
    context.read<AuthBloc>().add(
      ResetPasswordRequested(
        email: _emailCtrl.text.trim(),
        otp: otp,
        newPassword: pass,
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentSuccess) {
          setState(() {
            _step = 1;
            _errorText = null;
          });
          _snack('Đã gửi mã OTP! Kiểm tra console server.');
        } else if (state is PasswordResetSuccess) {
          _snack('Đặt lại mật khẩu thành công!');
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        } else if (state is AuthFailure) {
          setState(() => _errorText = state.failure.message);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Quên Mật Khẩu'),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStepIndicator(isDark),
                  const SizedBox(height: 32),

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        _step == 0
                            ? Icons.email_outlined
                            : _step == 1
                            ? Icons.lock_reset_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 40,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    _step == 0
                        ? 'Nhập Email'
                        : _step == 1
                        ? 'Xác Minh & Đặt Mật Khẩu Mới'
                        : 'Hoàn Tất',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _step == 0
                        ? 'Nhập email tài khoản để nhận mã xác nhận OTP.'
                        : _step == 1
                        ? 'Nhập mã OTP 6 số (xem trong console server)\nvà mật khẩu mới.'
                        : 'Mật khẩu đã được đặt lại thành công!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  if (_errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_step == 0) ...[
                    _inputField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'example@lms.edu.vn',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                      cs: cs,
                    ),
                    const SizedBox(height: 20),
                    _actionButton(
                      label: 'Gửi Mã OTP',
                      icon: Icons.send_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _sendOtp,
                    ),
                  ],

                  if (_step == 1) ...[
                    _inputField(
                      controller: _otpCtrl,
                      label: 'Mã OTP',
                      hint: '6 chữ số',
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                      cs: cs,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _inputField(
                      controller: _passCtrl,
                      label: 'Mật khẩu mới',
                      hint: 'Ít nhất 6 ký tự',
                      icon: Icons.lock_outline_rounded,
                      isDark: isDark,
                      cs: cs,
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _inputField(
                      controller: _confirmCtrl,
                      label: 'Xác nhận mật khẩu',
                      hint: 'Nhập lại mật khẩu mới',
                      icon: Icons.lock_outline_rounded,
                      isDark: isDark,
                      cs: cs,
                      obscure: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _actionButton(
                      label: 'Đặt Lại Mật Khẩu',
                      icon: Icons.lock_reset_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _resetPassword,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _step = 0;
                          _otpCtrl.clear();
                          _passCtrl.clear();
                          _confirmCtrl.clear();
                          _errorText = null;
                        });
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Quay lại nhập email'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    const labels = ['Email', 'Xác minh', 'Hoàn tất'];
    const icons = [
      Icons.email_outlined,
      Icons.lock_reset_rounded,
      Icons.check_circle_outline_rounded,
    ];

    return Row(
      children: List.generate(labels.length, (i) {
        final isActive = i == _step;
        final isDone = i < _step;
        final color = isActive
            ? const Color(0xFF6366F1)
            : isDone
            ? AppColors.success
            : (isDark ? Colors.white24 : Colors.grey.shade300);

        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone
                        ? AppColors.success
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isDone
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(color: color, width: isActive ? 2 : 1),
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : icons[i],
                  size: 16,
                  color: color,
                ),
              ),
              if (i < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone
                        ? AppColors.success
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ColorScheme cs,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
