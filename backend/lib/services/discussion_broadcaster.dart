import 'dart:convert';
import 'dart:io';

class DiscussionBroadcaster {
  final Map<int, Set<WebSocket>> _rooms = {};

  void joinRoom(int lessonId, WebSocket socket) {
    _rooms.putIfAbsent(lessonId, () => {});
    _rooms[lessonId]!.add(socket);

    socket.done.then((_) {
      _rooms[lessonId]?.remove(socket);
      if (_rooms[lessonId]?.isEmpty ?? false) {
        _rooms.remove(lessonId);
      }
    });
  }

  void broadcast(int lessonId, Map<String, dynamic> event) {
    final sockets = _rooms[lessonId];
    if (sockets == null) return;

    final message = jsonEncode(event);
    final stale = <WebSocket>[];

    for (final socket in sockets) {
      try {
        socket.add(message);
      } catch (_) {
        stale.add(socket);
      }
    }

    for (final s in stale) {
      sockets.remove(s);
    }
  }

  void onNewComment(int lessonId, Map<String, dynamic> commentData) {
    broadcast(lessonId, {
      'type': 'new_comment',
      'data': commentData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void onVoteUpdate(int lessonId, int commentId, int upvotes, int downvotes) {
    broadcast(lessonId, {
      'type': 'vote_update',
      'data': {
        'commentId': commentId,
        'upvotes': upvotes,
        'downvotes': downvotes,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void onModeration(int lessonId, int commentId, String action) {
    broadcast(lessonId, {
      'type': 'moderation',
      'data': {
        'commentId': commentId,
        'action': action,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Map<String, int> get roomStats {
    return _rooms.map((k, v) => MapEntry(k.toString(), v.length));
  }

  int get totalConnections => _rooms.values.fold(0, (s, set) => s + set.length);
}
