import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/quiz/domain/entities/quiz_entity.dart';
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
import '../../features/roadmap/presentation/pages/path_detail_page.dart';
import '../../features/roadmap/data/learning_paths_data.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/search/presentation/pages/global_search_page.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/quiz/presentation/pages/generate_quiz_page.dart';
import '../../features/quiz/presentation/pages/take_quiz_page.dart';
import '../../features/quiz/presentation/pages/quiz_result_page.dart';
import '../../features/quiz/presentation/pages/my_quizzes_page.dart';
import '../../features/quiz/presentation/pages/quiz_statistics_page.dart';
import '../../features/quiz/presentation/pages/leaderboard_page.dart';
import '../../features/quiz/presentation/pages/multiplayer_lobby_page.dart';
import '../../features/quiz/presentation/pages/multiplayer_game_page.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../features/quiz/presentation/bloc/leaderboard/leaderboard_bloc.dart';
import '../../features/quiz/presentation/bloc/multiplayer/multiplayer_bloc.dart';
import '../../features/analytics/presentation/pages/analytics_dashboard_page.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/discussion/presentation/pages/discussion_list_page.dart';
import '../../features/discussion/presentation/pages/discussion_thread_page.dart';
import '../../features/discussion/presentation/bloc/discussion_bloc.dart';
import '../../features/profile/presentation/pages/achievements_page.dart';
import '../../features/profile/presentation/bloc/achievement_bloc.dart';
import '../../features/offline/presentation/pages/offline_management_page.dart';
import '../../features/offline/presentation/bloc/offline_bloc.dart';
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
      case AppRoutes.studentHome:
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

      case AppRoutes.pathDetail:
        final path = settings.arguments as LearningPath;
        return MaterialPageRoute(builder: (_) => PathDetailPage(path: path));

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<NotificationBloc>(),
            child: const NotificationsPage(),
          ),
        );

      case AppRoutes.conversations:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: const ConversationsPage(),
          ),
        );

      case AppRoutes.chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: ChatRoomPage(
              conversationId: args['conversationId'] as int,
              participantName: args['participantName'] as String,
              isTeacher: args['isTeacher'] as bool? ?? false,
            ),
          ),
        );

      case AppRoutes.globalSearch:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<SearchBloc>(),
            child: const GlobalSearchPage(),
          ),
        );

      case AppRoutes.generateQuiz:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => GenerateQuizPage(
            isForMultiplayer: args?['isForMultiplayer'] as bool? ?? false,
            videoUrl: args?['videoUrl'] as String?,
            lessonTitle: args?['lessonTitle'] as String?,
          ),
        );

      case AppRoutes.takeQuiz:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<QuizBloc>(),
            child: TakeQuizPage(quiz: args['quiz']),
          ),
        );

      case AppRoutes.quizResult:
        final result = settings.arguments as QuizResultEntity;
        return MaterialPageRoute(
          builder: (_) => QuizResultPage(result: result),
        );

      case AppRoutes.myQuizzes:
        final userId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<QuizBloc>(),
            child: MyQuizzesPage(userId: userId),
          ),
        );

      case AppRoutes.quizStatistics:
        final userId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<QuizBloc>(),
            child: QuizStatisticsPage(userId: userId),
          ),
        );

      case AppRoutes.leaderboard:
        final classId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LeaderboardBloc>(),
            child: LeaderboardPage(classId: classId),
          ),
        );

      case AppRoutes.multiplayerLobby:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<MultiplayerBloc>(),
            child: const MultiplayerLobbyPage(),
          ),
        );

      case AppRoutes.multiplayerGame:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<MultiplayerBloc>(),
            child: const MultiplayerGamePage(),
          ),
        );

      case AppRoutes.analytics:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AnalyticsBloc>(),
            child: AnalyticsDashboardPage(
              userId: args['userId'] as int,
              courseId: args['courseId'] as int?,
            ),
          ),
        );

      case AppRoutes.discussions:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<DiscussionBloc>(),
            child: DiscussionListPage(
              courseId: args['courseId'] as int,
              courseTitle: args['courseTitle'] as String,
              lessonIds: args['lessonIds'] as List<int>,
            ),
          ),
        );

      case AppRoutes.discussionThread:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<DiscussionBloc>(),
            child: DiscussionThreadPage(
              lessonId: args['lessonId'] as int,
              userId: args['userId'] as int,
              lessonTitle: args['lessonTitle'] as String,
            ),
          ),
        );

      case AppRoutes.achievements:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AchievementBloc>(),
            child: const AchievementsPage(),
          ),
        );

      case AppRoutes.offlineManagement:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<OfflineBloc>(),
            child: const OfflineManagementPage(),
          ),
        );

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
