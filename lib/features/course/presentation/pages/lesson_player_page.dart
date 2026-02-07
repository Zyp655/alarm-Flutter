import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/lesson_entity.dart';
import '../bloc/learning_player_bloc.dart';
import '../bloc/learning_player_event.dart';
import '../../../../injection_container.dart';
import 'module_quiz_page.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/route/app_route.dart';

import '../widgets/assignment_submission_widget.dart';

class LessonPlayerPage extends StatelessWidget {
  final LessonEntity lesson;
  final int userId;
  final int? startPosition;
  final LessonEntity? previousLesson;
  final LessonEntity? nextLesson;

  const LessonPlayerPage({
    super.key,
    required this.lesson,
    required this.userId,
    this.startPosition,
    this.previousLesson,
    this.nextLesson,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LearningPlayerBloc>(),
      child: LessonPlayerView(
        lesson: lesson,
        userId: userId,
        startPosition: startPosition,
        previousLesson: previousLesson,
        nextLesson: nextLesson,
      ),
    );
  }
}

class LessonPlayerView extends StatefulWidget {
  final LessonEntity lesson;
  final int userId;
  final int? startPosition;
  final LessonEntity? previousLesson;
  final LessonEntity? nextLesson;

  const LessonPlayerView({
    super.key,
    required this.lesson,
    required this.userId,
    this.startPosition,
    this.previousLesson,
    this.nextLesson,
  });

  @override
  State<LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<LessonPlayerView>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Timer? _progressTimer;
  bool _isInitialized = false;
  String? _errorMessage;
  late TabController _tabController;

  Duration _maxWatchedPosition = Duration.zero;
  bool _isSeeking = false;
  bool _hasMarkedComplete = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.lesson.type == LessonType.assignment) {
      setState(() => _isInitialized = true);
      return;
    }

    if (widget.lesson.contentUrl == null || widget.lesson.contentUrl!.isEmpty) {
      setState(() => _errorMessage = 'Không tìm thấy URL video');
      return;
    }

    var finalUrl = widget.lesson.contentUrl!;

    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      final baseUrl = ApiConstants.baseUrl;
      if (finalUrl.startsWith('/')) {
        finalUrl = '$baseUrl$finalUrl';
      } else {
        finalUrl = '$baseUrl/$finalUrl';
      }
    }

    try {
      if (Platform.isAndroid && finalUrl.contains('localhost')) {
        finalUrl = finalUrl.replaceFirst('localhost', '10.0.2.2');
      }

      print('Playing video from: $finalUrl');

      _videoController = VideoPlayerController.networkUrl(Uri.parse(finalUrl));

      await _videoController!.initialize();

      if (widget.startPosition != null && widget.startPosition! > 0) {
        final start = Duration(seconds: widget.startPosition!);
        _maxWatchedPosition = start;
        await _videoController!.seekTo(start);
      }

      _videoController!.addListener(_onVideoPositionChanged);

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFF6636),
          handleColor: const Color(0xFFFF6636),
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.white30,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6636)),
          ),
        ),
      );

      _startProgressTracking();
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() {
        _errorMessage =
            'Lỗi khởi tạo video: ${e.toString()}\n\nURL gốc: ${widget.lesson.contentUrl}\nURL xử lý: $finalUrl';
      });
    }
  }

  void _onVideoPositionChanged() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    final currentPos = _videoController!.value.position;
    final totalDuration = _videoController!.value.duration;

    if (currentPos > _maxWatchedPosition) {
      if (currentPos - _maxWatchedPosition < const Duration(seconds: 2)) {
        _maxWatchedPosition = currentPos;
      }
    }

    if (currentPos > _maxWatchedPosition + const Duration(seconds: 5)) {
      if (!_isSeeking) {
        _isSeeking = true;
        _videoController!.seekTo(_maxWatchedPosition);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Bạn chưa thể tua qua phần này! Hãy học tuần tự.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          _isSeeking = false;
        });
      }
    }

    if (!_hasMarkedComplete && totalDuration.inSeconds > 0) {
      final percentWatched = currentPos.inSeconds / totalDuration.inSeconds;
      final isNearEnd = totalDuration.inSeconds - currentPos.inSeconds <= 3;

      if (percentWatched >= 0.95 || isNearEnd) {
        _hasMarkedComplete = true;
        _onVideoComplete();
        _autoNavigateToNextLesson();
      }
    }
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_videoController != null && _videoController!.value.isPlaying) {
        final position = _videoController!.value.position.inSeconds;
        context.read<LearningPlayerBloc>().add(
          UpdateProgressEvent(
            userId: widget.userId,
            lessonId: widget.lesson.id,
            currentPosition: position,
          ),
        );
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _onVideoComplete() {
    context.read<LearningPlayerBloc>().add(
      MarkLessonCompleteEvent(
        userId: widget.userId,
        lessonId: widget.lesson.id,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã hoàn thành bài học!'),
          ],
        ),
        backgroundColor: Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _autoNavigateToNextLesson() {
    if (widget.nextLesson != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.arrow_forward, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Đang chuyển đến: ${widget.nextLesson!.title}'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF6636),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.lessonPlayer,
            arguments: {
              'lesson': widget.nextLesson,
              'userId': widget.userId,
              'previousLesson': widget.lesson,
              'nextLesson': null,
            },
          );
        }
      });
    }
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.removeListener(_onVideoPositionChanged);
      final position = _videoController!.value.position.inSeconds;
      context.read<LearningPlayerBloc>().add(
        UpdateProgressEvent(
          userId: widget.userId,
          lessonId: widget.lesson.id,
          currentPosition: position,
        ),
      );
    }
    _progressTimer?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoSection(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(),

                          _buildNotesTab(),
                          _buildResourcesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildVideoSection() {
    if (widget.lesson.type == LessonType.assignment) {
      return Container(
        height: 600,
        color: Colors.white,
        child: AssignmentSubmissionWidget(
          assignmentId: widget.lesson.id,
          studentId: widget.userId,
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 240,
          color: Colors.black,
          child: _isInitialized
              ? Chewie(controller: _chewieController!)
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6636)),
                ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFF6636),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFFFF6636),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Ghi chú'),
          Tab(text: 'Tài liệu'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    String durationText = '${widget.lesson.durationMinutes} phút';

    if (_isInitialized &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      final duration = _videoController!.value.duration;
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      durationText = '$minutes phút $seconds giây';
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.lesson.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(Icons.access_time, durationText),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.remove_red_eye_outlined, 'Video'),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionCard(
          'Bài kiểm tra chương',
          'Làm bài kiểm tra do giáo viên tạo',
          Icons.quiz,
          const Color(0xFFFF6636),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ModuleQuizPage(
                  moduleId: widget.lesson.moduleId,
                  moduleTitle: widget.lesson.title,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Nội dung bài học',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          widget.lesson.textContent ?? 'Chưa có nội dung văn bản.',
          style: TextStyle(color: Colors.grey[600], height: 1.6),
        ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Ghi lại những điểm quan trọng...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã lưu ghi chú')));
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Lưu ghi chú'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có tài liệu đính kèm',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    ).animate().scale();
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () {
                if (widget.previousLesson != null) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.lessonPlayer,
                    arguments: {
                      'lesson': widget.previousLesson,
                      'userId': widget.userId,
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đây là bài học đầu tiên')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Icon(Icons.skip_previous, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _onVideoComplete,
                icon: const Icon(Icons.menu_book, size: 20),
                label: const Text(
                  'Đang học',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                if (widget.nextLesson != null) {
                  context.read<LearningPlayerBloc>().add(
                    MarkLessonCompleteEvent(
                      userId: widget.userId,
                      lessonId: widget.lesson.id,
                    ),
                  );
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.lessonPlayer,
                    arguments: {
                      'lesson': widget.nextLesson,
                      'userId': widget.userId,
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đây là bài học cuối cùng')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Icon(Icons.skip_next, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
