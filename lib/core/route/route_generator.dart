import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/main_wrapper_page.dart';
import '../../features/teaching/presentation/pages/teacher_home_page.dart';
import 'app_route.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => SignUpPage());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());

      case AppRoutes.schedule:
        return MaterialPageRoute(builder: (_) => const MainWrapperPage());
      case AppRoutes.teacherHome:
        return MaterialPageRoute(builder: (_) => const TeacherHomePage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy trang này!')),
      );
    });
  }
}