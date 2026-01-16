import 'dart:math';
import 'package:backend/repositories/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final repo = context.read<UserRepository>();
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String;

  final user = await repo.getUserByEmail(email);
  if (user == null) {
    return Response.json(
        body: {'message': 'Nếu email tồn tại, mã OTP đã được gửi.'});
  }

  final otp = (100000 + Random().nextInt(900000)).toString();

  await repo.saveResetToken(email, otp);

  await _sendEmail(email, otp);

  return Response.json(body: {'message': 'Đã gửi mã OTP'});
}

Future<void> _sendEmail(String recipient, String otp) async {
  final username = 'your_email@gmail.com';
  final password = 'your_google_app_password';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Alarm App Support')
    ..recipients.add(recipient)
    ..subject = 'Đặt lại mật khẩu - Alarm App'
    ..text = 'Mã xác nhận của bạn là: $otp. Mã có hiệu lực trong 15 phút.';

  try {
    await send(message, smtpServer);
  } catch (e) {
    print('Lỗi gửi mail: $e');
  }
}
