import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required int userId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  });

  Future<void> markNotificationAsRead(int notificationId);

  Future<void> markAllNotificationsAsRead(int userId);

  Future<void> deleteNotification(int notificationId);

  Future<int> getUnreadCount(int userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  NotificationRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://localhost:8080',
  });

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    required int userId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final queryParams = {
      'userId': userId.toString(),
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (unreadOnly) 'unreadOnly': 'true',
    };

    final uri = Uri.parse(
      '$baseUrl/notifications',
    ).replace(queryParameters: queryParams);

    final headers = await _getHeaders();
    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    final uri = Uri.parse('$baseUrl/notifications/$notificationId/read');

    final headers = await _getHeaders();
    final response = await client.put(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(int userId) async {
    final uri = Uri.parse(
      '$baseUrl/notifications/mark-all-read',
    ).replace(queryParameters: {'userId': userId.toString()});

    final headers = await _getHeaders();
    final response = await client.put(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    final uri = Uri.parse('$baseUrl/notifications/$notificationId/delete');

    final headers = await _getHeaders();
    final response = await client.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  @override
  Future<int> getUnreadCount(int userId) async {
    final notifications = await getNotifications(
      userId: userId,
      unreadOnly: true,
    );
    return notifications.length;
  }
}
