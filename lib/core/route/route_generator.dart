import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/main_wrapper_page.dart';
import '../../features/teaching/presentation/pages/teacher_home_page.dart';
import '../../features/course/presentation/pages/course_catalog_page.dart';
import '../../features/course/presentation/pages/course_detail_page.dart';
import '../../features/course/presentation/pages/lesson_player_page.dart';
import '../../features/course/presentation/pages/my_courses_page.dart';
import '../../features/course/presentation/bloc/course_list_bloc.dart';
import '../../features/course/domain/entities/lesson_entity.dart';
import '../../features/course/domain/entities/module_entity.dart';
import '../../injection_container.dart';
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

      case AppRoutes.courseCatalog:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<CourseListBloc>(),
            child: const CourseCatalogPage(),
          ),
        );

      case AppRoutes.courseDetail:
        final courseId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => CourseDetailPage(courseId: courseId),
        );

      case AppRoutes.lessonPlayer:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LessonPlayerPage(
            lesson: args['lesson'] as LessonEntity,
            userId: args['userId'] as int,
            startPosition: args['startPosition'] as int?,
            previousLesson: args['previousLesson'] as LessonEntity?,
            nextLesson: args['nextLesson'] as LessonEntity?,
            allModules: args['allModules'] as List<ModuleEntity>?,
          ),
        );

      case AppRoutes.myCourses:
        final userId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => MyCoursesPage(userId: userId));

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Lỗi')),
          body: const Center(child: Text('Không tìm thấy trang này!')),
        );
      },
    );
  }
}
