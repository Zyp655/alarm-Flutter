import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/face_verification_guard.dart';

class PlatformCamera {
  CameraController? _controller;
  bool _initialized = false;
  Timer? _captureTimer;

  String _lastEmotion = 'neutral';
  double _lastConfidence = 0;

  FaceVerificationGuard? _verificationGuard;

  void Function(String emotion, double confidence)? onLocalDetection;
  void Function(bool isOwner)? onIdentityCheck;

  bool get isInitialized => _initialized;
  bool get needsOpenAiConfirmation => true;
  String get lastEmotion => _lastEmotion;
  double get lastConfidence => _lastConfidence;
  bool get gazeStill => false;
  bool get eyeLocked => false;

  void resetConfirmationFlag() {}

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No cameras available');

    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _controller!.initialize();
    _initialized = true;
  }

  void setupVerificationGuard(int userId) {
    _verificationGuard = FaceVerificationGuard(
      userId: userId,
      onVerificationResult: (isOwner) {
        onIdentityCheck?.call(isOwner);
      },
    );
    _verificationGuard!.loadStoredEmbeddings();
  }

  void startVerificationStream() {
    if (_controller == null || !_initialized || _verificationGuard == null) return;

    _controller!.startImageStream((image) {
      _verificationGuard!.verifyFromCameraImage(image, _controller!.description);
    });
  }

  void stopVerificationStream() {
    try {
      _controller?.stopImageStream();
    } catch (_) {}
  }

  Future<Uint8List?> captureImage() async {
    if (_controller == null || !_initialized) return null;
    final image = await _controller!.takePicture();
    return await image.readAsBytes();
  }

  Widget buildPreview() {
    if (_controller == null || !_initialized) return const SizedBox.shrink();
    return CameraPreview(_controller!);
  }

  void dispose() {
    _captureTimer?.cancel();
    _captureTimer = null;
    try {
      _controller?.stopImageStream();
    } catch (_) {}
    _controller?.dispose();
    _controller = null;
    _initialized = false;
  }
}
