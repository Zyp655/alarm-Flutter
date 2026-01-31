import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:backend/services/game_manager.dart';

Future<Response> onRequest(RequestContext context, String code) async {
  final handler = webSocketHandler((channel, protocol) {
    GameManager().join(code, channel);
  });
  return handler(context);
}
