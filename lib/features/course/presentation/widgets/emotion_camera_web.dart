import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;

@JS('initFaceApi')
external JSPromise<JSBoolean?> _jsInitFaceApi();

@JS('EmotionCam.init')
external JSPromise<JSBoolean?> _jsCamInit();

@JS('EmotionCam.getVideo')
external JSObject? _jsCamGetVideo();

@JS('EmotionCam.detect')
external JSPromise<JSString?> _jsCamDetect();

@JS('EmotionCam.capture')
external JSString? _jsCamCapture();

@JS('EmotionCam.stop')
external void _jsCamStop();

class PlatformCamera {
  bool _initialized = false;
  bool _faceApiReady = false;
  String? _viewId;
  Timer? _detectTimer;

  String _lastEmotion = 'neutral';
  double _lastConfidence = 0;
  int _negativeStreak = 0;
  bool _needsConfirmation = false;
  void Function(String emotion, double confidence)? onLocalDetection;

  bool get isInitialized => _initialized;
  bool get needsOpenAiConfirmation => _needsConfirmation;
  String get lastEmotion => _lastEmotion;
  double get lastConfidence => _lastConfidence;

  void resetConfirmationFlag() => _needsConfirmation = false;

  Future<void> initialize() async {
    final camOk = await _jsCamInit().toDart;
    if (camOk?.toDart != true) {
      throw Exception('Camera init failed');
    }

    final videoEl = _jsCamGetVideo();
    if (videoEl == null) {
      throw Exception('No video element');
    }

    _viewId = 'emotion-cam-${DateTime.now().millisecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId!,
      (int viewId) => videoEl,
    );

    _initialized = true;

    try {
      final result = await _jsInitFaceApi().toDart;
      _faceApiReady = result?.toDart ?? false;
      debugPrint('[EmotionCamera] FaceAPI ready: $_faceApiReady');
    } catch (e) {
      debugPrint('[EmotionCamera] FaceAPI init failed: $e');
      _faceApiReady = false;
    }

    if (_faceApiReady) {
      _detectTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _detectLocal(),
      );
    }
  }

  Future<void> _detectLocal() async {
    if (!_faceApiReady || !_initialized) return;

    try {
      final result = await _jsCamDetect().toDart;
      if (result == null) return;

      final data = jsonDecode(result.toDart) as Map<String, dynamic>;
      final emotion = data['emotion'] as String? ?? 'neutral';
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0;

      _lastEmotion = _mapEmotion(emotion);
      _lastConfidence = confidence;

      onLocalDetection?.call(_lastEmotion, _lastConfidence);

      if (_isNegativeEmotion(_lastEmotion) && _lastConfidence >= 0.5) {
        _negativeStreak++;
      } else {
        _negativeStreak = 0;
      }

      if (_negativeStreak >= 4) {
        _needsConfirmation = true;
        _negativeStreak = 0;
      }
    } catch (e) {
      debugPrint('[EmotionCamera] Detection error: $e');
    }
  }

  String _mapEmotion(String faceApiEmotion) {
    switch (faceApiEmotion) {
      case 'sad':
      case 'fearful':
        return 'confused';
      case 'angry':
      case 'disgusted':
        return 'frustrated';
      case 'neutral':
        return 'neutral';
      case 'happy':
        return 'happy';
      case 'surprised':
        return 'focused';
      default:
        return 'neutral';
    }
  }

  bool _isNegativeEmotion(String emotion) {
    return emotion == 'confused' || emotion == 'frustrated' || emotion == 'bored';
  }

  Future<Uint8List?> captureImage() async {
    if (!_initialized) return null;
    try {
      final result = _jsCamCapture();
      if (result == null) return null;
      return base64Decode(result.toDart);
    } catch (e) {
      debugPrint('[EmotionCamera] Capture error: $e');
      return null;
    }
  }

  Widget buildPreview() {
    if (_viewId == null) return const SizedBox.shrink();
    return HtmlElementView(viewType: _viewId!);
  }

  void dispose() {
    _detectTimer?.cancel();
    _detectTimer = null;
    _jsCamStop();
    _initialized = false;
    _faceApiReady = false;
  }
}
