import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SegmentQuizOverlay extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final int segmentIndex;
  final int attemptCount;
  final String segmentTimeRange;
  final void Function(int answerIndex) onAnswer;
  final VoidCallback onDismiss;

  const SegmentQuizOverlay({
    super.key,
    required this.quizData,
    required this.segmentIndex,
    required this.attemptCount,
    required this.segmentTimeRange,
    required this.onAnswer,
    required this.onDismiss,
  });

  @override
  State<SegmentQuizOverlay> createState() => _SegmentQuizOverlayState();
}

class _SegmentQuizOverlayState extends State<SegmentQuizOverlay>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _answered = false;
  bool? _wasCorrect;
  String? _feedbackMessage;
  late AnimationController _slideController;
  late AnimationController _feedbackController;
  late Animation<double> _slideAnim;
  late Animation<double> _feedbackScale;
  late Animation<double> _backdropAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    );
    _feedbackScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );
    _backdropAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedIndex == null || _answered) return;
    setState(() => _answered = true);
    widget.onAnswer(_selectedIndex!);
  }

  void updateResult({
    required bool correct,
    required String message,
    required bool shouldRewind,
  }) {
    if (!mounted) return;
    setState(() {
      _wasCorrect = correct;
      _feedbackMessage = message;
    });
    _feedbackController.forward();
    if (correct) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) widget.onDismiss();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = AppColors.isDark(context);
    final question = widget.quizData['question'] as String? ?? '';
    final options =
        (widget.quizData['options'] as List<dynamic>?)?.cast<String>() ?? [];

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.black
                      .withValues(alpha: 0.6 * _backdropAnim.value),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8 * _backdropAnim.value,
                  sigmaY: 8 * _backdropAnim.value,
                ),
                child: const SizedBox.shrink(),
              ),
            ),
            Center(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_slideAnim),
                child: FadeTransition(
                  opacity: _slideAnim,
                  child: _buildCard(cs, isDark, question, options),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    ColorScheme cs,
    bool isDark,
    String question,
    List<String> options,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF111B2E), Color(0xFF1A2742)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFEFEFF), Color(0xFFF5F7FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(cs, isDark),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        height: 1.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      options.length,
                      (i) => _buildOption(cs, isDark, options[i], i),
                    ),
                    if (_feedbackMessage != null) _buildFeedback(cs),
                    const SizedBox(height: 12),
                    _buildActions(cs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.12),
            AppColors.accent.withValues(alpha: 0.04),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.quiz_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu hỏi phân đoạn ${widget.segmentIndex + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: cs.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.segmentTimeRange,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (widget.attemptCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Lần ${widget.attemptCount + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(
    ColorScheme cs,
    bool isDark,
    String text,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    final labels = ['A', 'B', 'C', 'D'];

    Color borderColor = cs.outline.withValues(alpha: 0.15);
    Color bgColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.grey.withValues(alpha: 0.04);
    Color labelBg = cs.surfaceContainerHighest;
    Color labelColor = cs.onSurfaceVariant;

    if (_answered && _wasCorrect != null) {
      final correctIdx = widget.quizData['correctIndex'] as int? ?? 0;
      if (index == correctIdx) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.08);
        labelBg = AppColors.success;
        labelColor = Colors.white;
      } else if (index == _selectedIndex && !_wasCorrect!) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.08);
        labelBg = AppColors.error;
        labelColor = Colors.white;
      }
    } else if (isSelected) {
      borderColor = AppColors.accent;
      bgColor = AppColors.accent.withValues(alpha: 0.08);
      labelBg = AppColors.accent;
      labelColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _answered ? null : () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.accent.withValues(alpha: 0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: labelBg,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.25),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: labelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                _buildTrailingIcon(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingIcon(int index) {
    if (_answered && _wasCorrect != null) {
      final correctIdx = widget.quizData['correctIndex'] as int? ?? 0;
      if (index == correctIdx) {
        return Icon(Icons.check_circle_rounded,
            size: 20, color: AppColors.success);
      } else if (index == _selectedIndex && !_wasCorrect!) {
        return Icon(Icons.cancel_rounded, size: 20, color: AppColors.error);
      }
    } else if (_selectedIndex == index) {
      return Icon(Icons.radio_button_checked, size: 20, color: AppColors.accent);
    }
    return const SizedBox.shrink();
  }

  Widget _buildFeedback(ColorScheme cs) {
    final isCorrect = _wasCorrect == true;
    final color = isCorrect ? AppColors.success : AppColors.error;
    return ScaleTransition(
      scale: _feedbackScale,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(
                isCorrect ? Icons.celebration_rounded : Icons.replay_rounded,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _feedbackMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme cs) {
    if (_answered && _wasCorrect == false) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            setState(() {
              _selectedIndex = null;
              _answered = false;
              _wasCorrect = null;
              _feedbackMessage = null;
            });
            _feedbackController.reset();
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Thử lại'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    if (!_answered) {
      return SizedBox(
        width: double.infinity,
        child: AnimatedOpacity(
          opacity: _selectedIndex != null ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: FilledButton(
            onPressed: _selectedIndex != null ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: _selectedIndex != null ? 4 : 0,
              shadowColor: AppColors.accent.withValues(alpha: 0.3),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
            child: const Text('Xác nhận câu trả lời'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
