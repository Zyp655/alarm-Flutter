import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PlatformCamera {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  bool _initialized = false;
  String? _viewId;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
      'video': {'facingMode': 'user', 'width': 160, 'height': 120},
      'audio': false,
    });

    _viewId = 'emotion-camera-${DateTime.now().millisecondsSinceEpoch}';
    _videoElement = html.VideoElement()
      ..srcObject = _mediaStream
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.transform = 'scaleX(-1)';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId!,
      (int viewId) => _videoElement!,
    );

    await _videoElement!.play();
    _initialized = true;
  }

  Future<Uint8List?> captureImage() async {
    if (_videoElement == null || !_initialized) return null;

    final canvas = html.CanvasElement(
      width: _videoElement!.videoWidth,
      height: _videoElement!.videoHeight,
    );
    canvas.context2D.drawImage(_videoElement!, 0, 0);

    final dataUrl = canvas.toDataUrl('image/jpeg', 0.7);
    final base64 = dataUrl.split(',').last;
    return base64Decode(base64);
  }

  Widget buildPreview() {
    if (_viewId == null) return const SizedBox.shrink();
    return HtmlElementView(viewType: _viewId!);
  }

  void dispose() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _videoElement?.pause();
    _videoElement?.srcObject = null;
    _videoElement = null;
    _initialized = false;
  }
}
