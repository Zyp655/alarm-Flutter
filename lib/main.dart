import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/common/theme_cubit.dart';
import 'core/route/app_route.dart';
import 'core/route/route_generator.dart';
import 'core/services/notification_service.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Alarm App',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
              ),
              cardColor: const Color(0xFF1E1E1E),
            ),

            themeMode: themeMode,

            initialRoute: AppRoutes.login,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}