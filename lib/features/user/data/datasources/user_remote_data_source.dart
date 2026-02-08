import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity_extended.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile(int userId);
  Future<void> updateUserProfile(UserEntityExtended user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserModel> getUserProfile(int userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/users/$userId');
    final headers = await _getHeaders();
    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        "Không thể tải thông tin cá nhân. Vui lòng thử lại sau.",
      );
    }
  }

  @override
  Future<void> updateUserProfile(UserEntityExtended user) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/users/${user.id}');
    final model = UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      token: user.token,
      className: user.className,
      studentId: user.studentId,
      department: user.department,
      teacherId: user.teacherId,
    );

    final headers = await _getHeaders();
    final response = await client.put(
      url,
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode != 200) {
      throw ServerException(
        "Không thể cập nhật thông tin. Vui lòng thử lại sau.",
      );
    }
  }
}
