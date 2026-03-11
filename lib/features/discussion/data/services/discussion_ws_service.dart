import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/api/api_constants.dart';

class DiscussionWsService {
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int? _currentLessonId;
  bool _isConnecting = false;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  bool get isConnected => _channel != null;

  void connect(int lessonId) {
    if (_currentLessonId == lessonId && _channel != null) return;

    disconnect();

    _isConnecting = true;
    _currentLessonId = lessonId;

    try {
      final wsBase = ApiConstants.baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final wsUrl = Uri.parse('$wsBase/discussions/ws?lessonId=$lessonId');

      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        _onMessage,
        onDone: () {
          _channel = null;
          _scheduleReconnect();
        },
        onError: (_) {
          _channel = null;
          _scheduleReconnect();
        },
      );

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      });
    } catch (e) {
      _scheduleReconnect();
    }

    _isConnecting = false;
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'new_comment' ||
          type == 'vote_update' ||
          type == 'moderation') {
        _eventController.add(data);
      }
    } catch (e) {
      debugPrint('[DiscussionWS.dispose] $e');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_currentLessonId != null && !_isConnecting) {
        connect(_currentLessonId!);
      }
    });
  }

  void disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _currentLessonId = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
