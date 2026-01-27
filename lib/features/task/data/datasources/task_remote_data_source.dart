import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(int userId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(int taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final http.Client client;

  TaskRemoteDataSourceImpl({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<TaskModel>> getTasks(int userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/tasks?userId=$userId');
    final headers = await _getHeaders();
    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => TaskModel.fromJson(e)).toList();
    } else {
      throw ServerException("Lỗi tải danh sách task: ${response.statusCode}");
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/tasks');
    final headers = await _getHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException("Lỗi tạo task: ${response.body}");
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/tasks/${task.id}');
    final headers = await _getHeaders();
    final response = await client.put(
      url,
      headers: headers,
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException("Lỗi cập nhật task: ${response.body}");
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/tasks/$taskId');
    final headers = await _getHeaders();
    final response = await client.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException("Lỗi xóa task: ${response.body}");
    }
  }
}
