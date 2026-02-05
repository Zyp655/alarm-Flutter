import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/route/app_route.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/utils/error_dialog_handler.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                },
                child: const Text("Quên mật khẩu?"),
              ),
            ),
            const SizedBox(height: 20),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ErrorDialogHandler.showError(context, state.failure);
                } else if (state is AuthSuccess) {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đăng nhập thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  if (state.user?.role == 1) {
                    Navigator.of(context).pushReplacementNamed('/teacher_home');
                  } else {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.schedule);
                  }
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const CircularProgressIndicator();
                }
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng nhập đầy đủ thông tin"),
                          ),
                        );
                        return;
                      }

                      context.read<AuthBloc>().add(
                        LoginRequested(email: email, password: password),
                      );
                    },
                    child: const Text(
                      "Đăng Nhập",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signUp);
                  },
                  child: const Text("Đăng ký ngay"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
