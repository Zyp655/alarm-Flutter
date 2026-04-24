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

@JS('EmotionCam.startLoop')
external void _jsCamStartLoop();

@JS('EmotionCam.capture')
external JSString? _jsCamCapture();

@JS('EmotionCam.stop')
external void _jsCamStop();

@JS('window.addEventListener')
external void _jsAddEventListener(JSString type, JSFunction callback);

@JS('window.removeEventListener')
external void _jsRemoveEventListener(JSString type, JSFunction callback);

extension type _EmotionEvent(JSObject _) implements JSObject {
  external JSString? get type;
  external JSObject? get data;
}

extension type _EmotionData(JSObject _) implements JSObject {
  external JSString? get type;
  external JSString? get emotion;
  external JSNumber? get confidence;
  external JSBoolean? get gazeStill;
  external JSBoolean? get eyeLocked;
}

class PlatformCamera {
  bool _initialized = false;
  bool _faceApiReady = false;
  String? _viewId;
  JSFunction? _jsListener;

  String _lastEmotion = 'neutral';
  double _lastConfidence = 0;
  int _negativeStreak = 0;
  bool _needsConfirmation = false;
  bool _gazeStill = false;
  bool _eyeLocked = false;
  void Function(String emotion, double confidence)? onLocalDetection;
  void Function(bool isOwner)? onIdentityCheck;

  bool get isInitialized => _initialized;
  bool get needsOpenAiConfirmation => _needsConfirmation;
  String get lastEmotion => _lastEmotion;
  double get lastConfidence => _lastConfidence;
  bool get gazeStill => _gazeStill;
  bool get eyeLocked => _eyeLocked;

  void resetConfirmationFlag() => _needsConfirmation = false;
  void setupVerificationGuard(int userId) {}
  void startVerificationStream() {}
  void stopVerificationStream() {}

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
      _listenToJsEvents();
      _jsCamStartLoop();
      debugPrint('[EmotionCamera] Real-time JS loop started');
    }
  }

  void _listenToJsEvents() {
    _jsListener = ((JSObject event) {
      try {
        final msgEvent = event as _EmotionEvent;
        final data = msgEvent.data;
        if (data == null) return;

        final emotionData = data as _EmotionData;
        final type = emotionData.type?.toDart;
        if (type != 'emotion_event') return;

        final emotion = emotionData.emotion?.toDart ?? 'neutral';
        final confidence = emotionData.confidence?.toDartDouble ?? 0.0;
        _gazeStill = emotionData.gazeStill?.toDart ?? false;
        _eyeLocked = emotionData.eyeLocked?.toDart ?? false;

        _processEmotion(emotion, confidence);
      } catch (_) {}
    }).toJS;

    _jsAddEventListener('message'.toJS, _jsListener!);
  }

  void _processEmotion(String emotion, double confidence) {
    if (!_initialized) return;

    if (emotion == 'no_face') {
      _lastEmotion = 'no_face';
      _lastConfidence = 0;
      onLocalDetection?.call('no_face', 0);
      return;
    }

    _lastEmotion = _mapEmotion(emotion);
    _lastConfidence = confidence;

    onLocalDetection?.call(_lastEmotion, _lastConfidence);

    if (_isNegativeEmotion(_lastEmotion) && _lastConfidence >= 0.3) {
      _negativeStreak++;
    } else {
      _negativeStreak = 0;
    }

    if (_negativeStreak >= 6) {
      _needsConfirmation = true;
      _negativeStreak = 0;
    }
  }

  String _mapEmotion(String faceApiEmotion) {
    switch (faceApiEmotion) {
      case 'confused':
        return 'confused';
      case 'frustrated':
        return 'frustrated';
      case 'sad':
      case 'fearful':
      case 'surprised':
        return 'confused';
      case 'angry':
      case 'disgusted':
        return 'frustrated';
      case 'happy':
        return 'happy';
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
    if (_jsListener != null) {
      _jsRemoveEventListener('message'.toJS, _jsListener!);
      _jsListener = null;
    }
    _jsCamStop();
    _initialized = false;
    _faceApiReady = false;
  }
}
