import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/utils/error_dialog_handler.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quên Mật Khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu.",
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ErrorDialogHandler.showError(context, state.failure);
                } else if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Đã gửi yêu cầu! Vui lòng kiểm tra email (hoặc console server).",
                      ),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading)
                  return const CircularProgressIndicator();
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        ForgotPasswordRequested(email: emailController.text),
                      );
                    },
                    child: const Text("Gửi yêu cầu"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
