import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/face_embedding_service.dart';

class FaceVerificationGuard {
  final int userId;
  final void Function(bool isOwner) onVerificationResult;

  FaceVerificationGuard({
    required this.userId,
    required this.onVerificationResult,
  });

  List<List<double>> _storedEmbeddings = [];
  bool _isLoaded = false;
  bool _isVerifying = false;
  DateTime? _lastVerifyTime;
  static const _verifyIntervalSeconds = 5;

  bool get isLoaded => _isLoaded;

  Future<void> loadStoredEmbeddings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final front = prefs.getStringList('face_front_$userId');
      final left = prefs.getStringList('face_left_$userId');
      final right = prefs.getStringList('face_right_$userId');

      _storedEmbeddings = [];

      if (front != null && front.isNotEmpty) {
        _storedEmbeddings.add(front.map((s) => double.parse(s)).toList());
      }
      if (left != null && left.isNotEmpty) {
        _storedEmbeddings.add(left.map((s) => double.parse(s)).toList());
      }
      if (right != null && right.isNotEmpty) {
        _storedEmbeddings.add(right.map((s) => double.parse(s)).toList());
      }

      _isLoaded = _storedEmbeddings.isNotEmpty;
    } catch (_) {
      _isLoaded = false;
    }
  }

  Future<void> verifyFromCameraImage(CameraImage image, CameraDescription camera) async {
    if (!_isLoaded || _isVerifying || _storedEmbeddings.isEmpty) return;

    final now = DateTime.now();
    if (_lastVerifyTime != null &&
        now.difference(_lastVerifyTime!).inSeconds < _verifyIntervalSeconds) {
      return;
    }

    _isVerifying = true;
    _lastVerifyTime = now;

    try {
      final service = FaceEmbeddingService.instance;
      if (!service.isInitialized) {
        _isVerifying = false;
        return;
      }

      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (rotation == null) {
        _isVerifying = false;
        return;
      }

      final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
      if (format == null) {
        _isVerifying = false;
        return;
      }

      final inputImage = InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await service.detectFaces(inputImage);
      if (faces.isEmpty) return;

      final face = faces.first;

      final nv21Bytes = image.planes.first.bytes;
      final decoded = _convertNV21ToImage(nv21Bytes, image.width, image.height);
      if (decoded == null) {
        _isVerifying = false;
        return;
      }

      final cropped = service.cropFaceFromImage(decoded, face.boundingBox);
      final embedding = await service.generateEmbeddingFromImage(cropped);
      if (embedding == null) {
        _isVerifying = false;
        return;
      }

      final isOwner = service.isMatchBySimilarity(embedding, _storedEmbeddings, threshold: 0.55);
      onVerificationResult(isOwner);
    } catch (_) {}

    _isVerifying = false;
  }

  img.Image? _convertNV21ToImage(Uint8List bytes, int width, int height) {
    try {
      final image = img.Image(width: width, height: height);
      final frameSize = width * height;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final yIndex = y * width + x;
          final uvIndex = frameSize + (y ~/ 2) * width + (x & ~1);

          if (yIndex >= bytes.length || uvIndex + 1 >= bytes.length) continue;

          final yValue = bytes[yIndex];
          final vValue = bytes[uvIndex];
          final uValue = bytes[uvIndex + 1];

          int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
          int g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128)).round().clamp(0, 255);
          int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
      return image;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isRegistered(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('face_registered_$userId') ?? false;
  }
}
