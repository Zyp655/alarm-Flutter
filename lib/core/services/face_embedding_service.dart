import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  static FaceEmbeddingService? _instance;
  static FaceEmbeddingService get instance => _instance ??= FaceEmbeddingService._();
  FaceEmbeddingService._();

  Interpreter? _interpreter;
  bool _isInitialized = false;
  late final FaceDetector _faceDetector;

  static const int _inputSize = 112;
  static const int _embeddingSize = 192;
  static const double _matchThreshold = 1.0;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    try {
      _interpreter = await Interpreter.fromAsset('models/mobilefacenet.tflite');
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<List<Face>> detectFaces(InputImage inputImage) async {
    return _faceDetector.processImage(inputImage);
  }

  double? getHeadYaw(Face face) {
    return face.headEulerAngleY;
  }

  HeadPose classifyHeadPose(Face face) {
    final yaw = face.headEulerAngleY ?? 0;
    if (yaw < -20) return HeadPose.left;
    if (yaw > 20) return HeadPose.right;
    return HeadPose.front;
  }

  Future<List<double>?> generateEmbeddingFromBytes(Uint8List imageBytes) async {
    if (!_isInitialized || _interpreter == null) return null;

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    final inputImage = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: Size(decoded.width.toDouble(), decoded.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: decoded.width,
      ),
    );

    final faces = await detectFaces(inputImage);
    if (faces.isEmpty) return null;

    final face = faces.first;
    final cropped = _cropFace(decoded, face.boundingBox);
    return _runModel(cropped);
  }

  Future<List<double>?> generateEmbeddingFromImage(img.Image image) async {
    if (!_isInitialized || _interpreter == null) return null;
    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);
    return _runModel(resized);
  }

  Future<List<double>?> generateEmbeddingFromCroppedBytes(Uint8List croppedFaceBytes) async {
    if (!_isInitialized || _interpreter == null) return null;
    final decoded = img.decodeImage(croppedFaceBytes);
    if (decoded == null) return null;
    return _runModel(decoded);
  }

  img.Image cropFaceFromImage(img.Image source, Rect boundingBox) {
    return _cropFace(source, boundingBox);
  }

  img.Image _cropFace(img.Image source, Rect bbox) {
    final x = bbox.left.clamp(0, source.width - 1).toInt();
    final y = bbox.top.clamp(0, source.height - 1).toInt();
    final w = bbox.width.clamp(1, source.width - x).toInt();
    final h = bbox.height.clamp(1, source.height - y).toInt();

    final cropped = img.copyCrop(source, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: _inputSize, height: _inputSize);
  }

  List<double> _runModel(img.Image faceImage) {
    final resized = img.copyResize(faceImage, width: _inputSize, height: _inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r.toDouble() - 128) / 128,
              (pixel.g.toDouble() - 128) / 128,
              (pixel.b.toDouble() - 128) / 128,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_embeddingSize, 0.0));
    _interpreter!.run(input, output);

    final norm = sqrt(output[0].fold<double>(0, (sum, v) => sum + v * v));
    if (norm > 0) {
      for (int i = 0; i < output[0].length; i++) {
        output[0][i] /= norm;
      }
    }

    return output[0];
  }

  double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) return double.infinity;
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return sqrt(sum);
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denominator = sqrt(normA) * sqrt(normB);
    if (denominator == 0) return 0;
    return dot / denominator;
  }

  bool isMatch(List<double> embedding, List<List<double>> storedEmbeddings) {
    for (final stored in storedEmbeddings) {
      final distance = euclideanDistance(embedding, stored);
      if (distance < _matchThreshold) return true;
    }
    return false;
  }

  bool isMatchBySimilarity(List<double> embedding, List<List<double>> storedEmbeddings, {double threshold = 0.6}) {
    for (final stored in storedEmbeddings) {
      final similarity = cosineSimilarity(embedding, stored);
      if (similarity >= threshold) return true;
    }
    return false;
  }

  void dispose() {
    _interpreter?.close();
    _faceDetector.close();
    _isInitialized = false;
    _instance = null;
  }
}

enum HeadPose { front, left, right }

class FaceRegistrationData {
  final Uint8List frontImage;
  final Uint8List leftImage;
  final Uint8List rightImage;
  final List<double> frontEmbedding;
  final List<double> leftEmbedding;
  final List<double> rightEmbedding;

  FaceRegistrationData({
    required this.frontImage,
    required this.leftImage,
    required this.rightImage,
    required this.frontEmbedding,
    required this.leftEmbedding,
    required this.rightEmbedding,
  });

  List<List<double>> get allEmbeddings => [frontEmbedding, leftEmbedding, rightEmbedding];
}
