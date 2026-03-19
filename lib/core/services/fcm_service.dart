import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../api/api_constants.dart';
import '../route/app_route.dart';
import '../route/app_router.dart';

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;
  final type = data['type'] as String? ?? '';

  String channelId = 'general_notifications';
  String channelName = 'Thông báo chung';

  if (type == 'chat_message') {
    channelId = 'chat_messages';
    channelName = 'Tin nhắn Chat';
  } else if (type == 'quiz_new' || type == 'assignment_new') {
    channelId = 'course_updates';
    channelName = 'Cập nhật khóa học';
  } else if (type == 'absence_warning') {
    channelId = 'ai_attendance';
    channelName = 'Cảnh báo vắng';
  }

  final title = notification?.title ?? data['title'] ?? 'Thông báo mới';
  final body = notification?.body ?? data['message'] ?? '';

  await _localNotificationsPlugin.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      ),
    ),
    payload: jsonEncode(data),
  );
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  int? _currentUserId;
  int? _activeConversationId;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;

  static const _channels = [
    AndroidNotificationChannel(
      'chat_messages',
      'Tin nhắn Chat',
      description: 'Thông báo khi có tin nhắn mới',
      importance: Importance.max,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'course_updates',
      'Cập nhật khóa học',
      description: 'Quiz mới, bài tập mới',
      importance: Importance.high,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'ai_attendance',
      'Cảnh báo vắng',
      description: 'Nhắc nhở hoàn thành bài học',
      importance: Importance.high,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'general_notifications',
      'Thông báo chung',
      description: 'Các thông báo khác',
      importance: Importance.defaultImportance,
    ),
  ];

  Future<void> init({required int userId}) async {
    _currentUserId = userId;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final channel in _channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }
    } catch (_) {}

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_sendTokenToServer);
  }

  void setActiveConversation(int? conversationId) {
    _activeConversationId = conversationId;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String? ?? '';

    if (type == 'chat_message') {
      final conversationId = int.tryParse(data['conversationId'] ?? '');
      if (conversationId == _activeConversationId) return;
    }

    _showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String? ?? '';

    if (type == 'chat_message') {
      final conversationId = int.tryParse(data['conversationId'] ?? '');
      final recipientName = data['senderName'] ?? '';
      if (conversationId != null) {
        _navigateToChat(conversationId, recipientName);
      }
    } else {
      final relatedId = int.tryParse(data['relatedId'] ?? '');
      if (relatedId != null) {
        _navigateToCourse(relatedId);
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final type = data['type'] as String? ?? '';

        if (type == 'chat_message') {
          final conversationId = int.tryParse(data['conversationId'] ?? '');
          final senderName = data['senderName'] ?? '';
          if (conversationId != null) {
            _navigateToChat(conversationId, senderName);
          }
        } else {
          final relatedId = int.tryParse(
              (data['relatedId'] ?? '').toString());
          if (relatedId != null) {
            _navigateToCourse(relatedId);
          }
        }
      } catch (_) {}
    }
  }

  void _navigateToChat(int conversationId, String recipientName) {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).push(
        AppRoutes.chatRoom,
        extra: {
          'conversationId': conversationId,
          'participantName': recipientName,
          'isTeacher': false,
        },
      );
    }
  }

  void _navigateToCourse(int courseId) {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).push('/courses/$courseId');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    if (_currentUserId == null) return;

    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/update-fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _currentUserId, 'fcmToken': token}),
      );
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _onMessageSub?.cancel();
    _tokenRefreshSub = null;
    _onMessageSub = null;
    _currentUserId = null;
    _activeConversationId = null;
  }
}
