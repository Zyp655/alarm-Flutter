import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/common/theme_cubit.dart';

Future<void> initCoreModule(GetIt sl) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => ApiClient(client: sl()));
  sl.registerLazySingleton(() => ThemeCubit());
}
