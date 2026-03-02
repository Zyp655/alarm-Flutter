import '../../../../core/api/api_client.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final user = UserModel.fromJson(response);

    if (user.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token!);
      await prefs.setInt('userId', user.id);
      if (user.departmentId != null) {
        await prefs.setInt('departmentId', user.departmentId!);
      } else {
        await prefs.remove('departmentId');
      }
    }

    return user;
  }

  @override
  Future<void> signUp(String email, String password) async {
    await apiClient.post('/auth/signup', {
      'email': email,
      'password': password,
    });
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post('/auth/forgot_password', {'email': email});
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await apiClient.post('/auth/reset_password', {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }
}
