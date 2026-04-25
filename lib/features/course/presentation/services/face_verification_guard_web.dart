import 'package:shared_preferences/shared_preferences.dart';

class FaceVerificationGuard {
  final int userId;
  final void Function(bool isOwner) onVerificationResult;

  FaceVerificationGuard({
    required this.userId,
    required this.onVerificationResult,
  });

  bool get isLoaded => false;

  Future<void> loadStoredEmbeddings() async {}

  Future<void> verifyFromCameraImage(dynamic image, dynamic camera) async {}

  static Future<bool> isRegistered(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('face_registered_$userId') ?? false;
  }
}
