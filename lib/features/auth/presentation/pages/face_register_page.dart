import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/face_embedding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/api_client.dart';
import '../../../../injection_container.dart';

class FaceRegisterPage extends StatefulWidget {
  final int userId;
  final VoidCallback onComplete;

  const FaceRegisterPage({
    super.key,
    required this.userId,
    required this.onComplete,
  });

  @override
  State<FaceRegisterPage> createState() => _FaceRegisterPageState();
}

enum _CaptureStep { front, left, right, confirm }

class _FaceRegisterPageState extends State<FaceRegisterPage> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  _CaptureStep _currentStep = _CaptureStep.front;

  Uint8List? _frontImage;
  Uint8List? _leftImage;
  Uint8List? _rightImage;

  bool _faceDetected = false;
  bool _poseCorrect = false;
  bool _isCapturing = false;
  String _guideText = 'Nhìn thẳng vào camera';
  Timer? _captureTimer;
  int _holdSeconds = 0;
  static const _requiredHoldSeconds = 2;

  late final FaceEmbeddingService _embeddingService;
  bool _isProcessing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _embeddingService = FaceEmbeddingService.instance;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initializeCamera();
    _initializeEmbedding();
  }

  Future<void> _initializeEmbedding() async {
    try {
      await _embeddingService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo AI: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _cameraController!.initialize();
    if (mounted) {
      setState(() => _isCameraReady = true);
      _startFaceTracking();
    }
  }

  void _startFaceTracking() {
    _cameraController?.startImageStream((image) {
      if (_isCapturing || _isProcessing || _currentStep == _CaptureStep.confirm) return;
      _processCameraFrame(image);
    });
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _embeddingService.detectFaces(inputImage);

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (faces.isEmpty) {
        setState(() {
          _faceDetected = false;
          _poseCorrect = false;
          _holdSeconds = 0;
        });
        _captureTimer?.cancel();
        _isProcessing = false;
        return;
      }

      final face = faces.first;
      final pose = _embeddingService.classifyHeadPose(face);
      final targetPose = _getTargetPose();
      final isCorrect = pose == targetPose;

      setState(() {
        _faceDetected = true;
        _poseCorrect = isCorrect;
      });

      if (isCorrect) {
        if (_captureTimer == null || !_captureTimer!.isActive) {
          _holdSeconds = 0;
          _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            setState(() => _holdSeconds++);
            if (_holdSeconds >= _requiredHoldSeconds) {
              timer.cancel();
              _captureCurrentStep();
            }
          });
        }
      } else {
        _captureTimer?.cancel();
        _holdSeconds = 0;
      }
    } catch (_) {}

    _isProcessing = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _cameraController!.description;
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
      if (format == null) return null;

      return InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  HeadPose _getTargetPose() {
    switch (_currentStep) {
      case _CaptureStep.front:
        return HeadPose.front;
      case _CaptureStep.left:
        return HeadPose.left;
      case _CaptureStep.right:
        return HeadPose.right;
      default:
        return HeadPose.front;
    }
  }

  Future<void> _captureCurrentStep() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      await _cameraController?.stopImageStream();
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();

      setState(() {
        switch (_currentStep) {
          case _CaptureStep.front:
            _frontImage = bytes;
            _currentStep = _CaptureStep.left;
            _guideText = 'Quay mặt sang trái';
            break;
          case _CaptureStep.left:
            _leftImage = bytes;
            _currentStep = _CaptureStep.right;
            _guideText = 'Quay mặt sang phải';
            break;
          case _CaptureStep.right:
            _rightImage = bytes;
            _currentStep = _CaptureStep.confirm;
            _guideText = 'Xác nhận hình ảnh';
            break;
          default:
            break;
        }
        _faceDetected = false;
        _poseCorrect = false;
        _holdSeconds = 0;
      });

      if (_currentStep != _CaptureStep.confirm) {
        await Future.delayed(const Duration(milliseconds: 500));
        _startFaceTracking();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    }

    _isCapturing = false;
  }

  void _retakePhotos() {
    setState(() {
      _frontImage = null;
      _leftImage = null;
      _rightImage = null;
      _currentStep = _CaptureStep.front;
      _guideText = 'Nhìn thẳng vào camera';
      _faceDetected = false;
      _poseCorrect = false;
    });
    _startFaceTracking();
  }

  Future<void> _confirmAndSave() async {
    if (_frontImage == null || _leftImage == null || _rightImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final frontDecoded = img.decodeImage(_frontImage!);
      final leftDecoded = img.decodeImage(_leftImage!);
      final rightDecoded = img.decodeImage(_rightImage!);

      if (frontDecoded == null || leftDecoded == null || rightDecoded == null) {
        throw Exception('Không thể xử lý ảnh');
      }

      final frontEmb = await _embeddingService.generateEmbeddingFromImage(frontDecoded);
      final leftEmb = await _embeddingService.generateEmbeddingFromImage(leftDecoded);
      final rightEmb = await _embeddingService.generateEmbeddingFromImage(rightDecoded);

      if (frontEmb == null || leftEmb == null || rightEmb == null) {
        throw Exception('Không thể tạo face embedding');
      }

      try {
        final api = sl<ApiClient>();
        await api.post('/face/register', {
          'userId': widget.userId,
          'frontEmbedding': frontEmb,
          'leftEmbedding': leftEmb,
          'rightEmbedding': rightEmb,
        });
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'face_front_${widget.userId}',
        frontEmb.map((e) => e.toString()).toList(),
      );
      await prefs.setStringList(
        'face_left_${widget.userId}',
        leftEmb.map((e) => e.toString()).toList(),
      );
      await prefs.setStringList(
        'face_right_${widget.userId}',
        rightEmb.map((e) => e.toString()).toList(),
      );
      await prefs.setBool('face_registered_${widget.userId}', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đăng ký khuôn mặt thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == _CaptureStep.confirm) {
      return _buildConfirmView();
    }
    return _buildCaptureView();
  }

  Widget _buildCaptureView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            const SizedBox(height: 16),
            Expanded(child: _buildCameraPreview()),
            _buildGuideFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Xác thực khuôn mặt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepChip('Nhìn thẳng', _CaptureStep.front, Icons.face),
          const SizedBox(width: 8),
          _buildStepChip('Quay trái', _CaptureStep.left, Icons.rotate_left),
          const SizedBox(width: 8),
          _buildStepChip('Quay phải', _CaptureStep.right, Icons.rotate_right),
        ],
      ),
    );
  }

  Widget _buildStepChip(String label, _CaptureStep step, IconData icon) {
    final isCurrent = _currentStep == step;
    final isDone = _currentStep.index > step.index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.success.withValues(alpha: 0.2)
            : isCurrent
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? AppColors.success
              : isCurrent
                  ? AppColors.accent
                  : Colors.white12,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle : icon,
            size: 16,
            color: isDone ? AppColors.success : isCurrent ? AppColors.accent : Colors.white38,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDone
                  ? AppColors.success
                  : isCurrent
                      ? Colors.white
                      : Colors.white38,
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _cameraController == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _poseCorrect ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: 280,
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(180),
            border: Border.all(
              color: _poseCorrect
                  ? AppColors.success
                  : _faceDetected
                      ? AppColors.warning
                      : Colors.red.shade400,
              width: 4,
            ),
            boxShadow: [
              if (_poseCorrect)
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(176),
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _poseCorrect
                  ? AppColors.success.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _poseCorrect ? AppColors.success.withValues(alpha: 0.4) : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _poseCorrect ? Icons.check_circle_outline : Icons.info_outline,
                  color: _poseCorrect ? AppColors.success : Colors.white60,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _poseCorrect
                      ? 'Giữ yên ${_requiredHoldSeconds - _holdSeconds}s...'
                      : _guideText,
                  style: TextStyle(
                    color: _poseCorrect ? AppColors.success : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_poseCorrect) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _holdSeconds / _requiredHoldSeconds,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            const Text(
              'Xác nhận sử dụng hình ảnh khuôn mặt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Những hình ảnh này sẽ được sử dụng cho mục đích xác thực danh tính khi bạn tham gia các bài học.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildPreviewCard('Nhìn thẳng', _frontImage),
                    const SizedBox(width: 12),
                    _buildPreviewCard('Quay trái', _leftImage),
                    const SizedBox(width: 12),
                    _buildPreviewCard('Quay phải', _rightImage),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _retakePhotos,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Chụp lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _confirmAndSave,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(_isProcessing ? 'Đang xử lý...' : 'Xác nhận'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(String label, Uint8List? imageBytes) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.white24, size: 32),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}
