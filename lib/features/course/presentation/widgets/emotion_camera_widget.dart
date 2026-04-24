import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'emotion_camera_web.dart' if (dart.library.io) 'emotion_camera_native.dart';

class EmotionCameraWidget extends StatefulWidget {
  final void Function(String emotion, double confidence, {bool gazeStill, bool eyeLocked}) onEmotionDetected;
  final void Function(bool isOwner)? onIdentityCheck;
  final bool isDetectionPaused;
  final int? userId;

  const EmotionCameraWidget({
    super.key,
    required this.onEmotionDetected,
    this.onIdentityCheck,
    this.isDetectionPaused = false,
    this.userId,
  });

  @override
  State<EmotionCameraWidget> createState() => _EmotionCameraWidgetState();
}

class _EmotionCameraWidgetState extends State<EmotionCameraWidget> {
  bool _isEnabled = false;
  bool _isInitializing = false;
  String _currentEmotion = 'neutral';
  PlatformCamera? _platformCamera;
  Offset _offset = Offset.zero;

  @override
  void dispose() {
    _platformCamera?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    setState(() => _isInitializing = true);

    try {
      _platformCamera = PlatformCamera();

      _platformCamera!.onLocalDetection = (emotion, confidence) {
        if (mounted && !widget.isDetectionPaused) {
          setState(() => _currentEmotion = emotion);
          widget.onEmotionDetected(
            emotion,
            confidence,
            gazeStill: _platformCamera?.gazeStill ?? false,
            eyeLocked: _platformCamera?.eyeLocked ?? false,
          );
        }
      };

      _platformCamera!.onIdentityCheck = (isOwner) {
        if (mounted) {
          widget.onIdentityCheck?.call(isOwner);
        }
      };

      await _platformCamera!.initialize();

      if (widget.userId != null && !kIsWeb) {
        _platformCamera!.setupVerificationGuard(widget.userId!);
        _platformCamera!.startVerificationStream();
      }

      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('[EmotionCamera] init error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isEnabled = false;
        });
      }
    }
  }

  Future<void> _stopCamera() async {
    _platformCamera?.dispose();
    _platformCamera = null;
  }

  Future<void> _toggle() async {
    if (_isEnabled) {
      await _stopCamera();
      setState(() {
        _isEnabled = false;
        _currentEmotion = 'neutral';
      });
    } else {
      setState(() => _isEnabled = true);
      await _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTop = MediaQuery.of(context).padding.top + 50;
    const defaultRight = 12.0;
    return Positioned(
      top: defaultTop + _offset.dy,
      right: defaultRight - _offset.dx,
      child: GestureDetector(
        onTap: _toggle,
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isEnabled ? 80 : 36,
              height: _isEnabled ? 65 : 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(_isEnabled ? 10 : 18),
                border: Border.all(
                  color: _isEnabled
                      ? _emotionColor().withValues(alpha: 0.8)
                      : Colors.white30,
                  width: 2,
                ),
              ),
              child: _isEnabled && _platformCamera != null && _platformCamera!.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _platformCamera!.buildPreview(),
                    )
                  : _isInitializing
                      ? const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.face_retouching_natural,
                          size: 18,
                          color: Colors.white54,
                        ),
            ),
          if (_isEnabled) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _emotionColor().withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _emotionLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Color _emotionColor() {
    switch (_currentEmotion) {
      case 'confused':
        return Colors.orange;
      case 'frustrated':
        return Colors.red;
      case 'bored':
        return Colors.grey;
      case 'focused':
        return AppColors.success;
      case 'happy':
        return AppColors.accent;
      case 'no_face':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _emotionLabel() {
    switch (_currentEmotion) {
      case 'confused':
        return '🤔 Bối rối';
      case 'frustrated':
        return '😤 Khó chịu';
      case 'bored':
        return '😴 Chán';
      case 'focused':
        return '🎯 Tập trung';
      case 'happy':
        return '😊 Vui';
      case 'no_face':
        return '👻 Không có mặt';
      default:
        return '😐 Bình thường';
    }
  }
}
