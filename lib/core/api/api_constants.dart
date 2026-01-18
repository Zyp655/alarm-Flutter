class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const String login = '$baseUrl/auth/login';
  static const String signUp = '$baseUrl/auth/sign_up';

  static const String createClass = '$baseUrl/teacher/create_class';
  static const String teacherSchedules = '$baseUrl/teacher/schedules';
  static const String updateScore ='$baseUrl/teacher/update_score';
}