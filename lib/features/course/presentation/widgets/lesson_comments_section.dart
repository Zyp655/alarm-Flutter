import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/comment_entity.dart';
import 'comment_card.dart';


class LessonCommentsSection extends StatefulWidget {
  final int lessonId;
  final List<CommentEntity> comments;
  final bool isStudent; 
  final int? currentUserId;
  final int? teacherId; 
  final Function(String content, int? parentId)? onPostComment;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const LessonCommentsSection({
    super.key,
    required this.lessonId,
    required this.comments,
    required this.isStudent,
    this.currentUserId,
    this.teacherId,
    this.onPostComment,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<LessonCommentsSection> createState() => _LessonCommentsSectionState();
}

class _LessonCommentsSectionState extends State<LessonCommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  int? _replyingTo;
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  List<CommentEntity> get _topLevelComments {
    return widget.comments.where((c) => c.parentId == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); 
  }

  List<CommentEntity> _getReplies(int parentId) {
    return widget.comments.where((c) => c.parentId == parentId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); 
  }

  void _handleSubmit() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || widget.onPostComment == null) return;

    setState(() => _isPosting = true);

    try {
      await widget.onPostComment!(content, _replyingTo);
      _commentController.clear();
      _replyingTo = null;
      setState(() => _isPosting = false);
    } catch (e) {
      setState(() => _isPosting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi bình luận: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(width: 8),
              Text(
                'Thảo luận',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.comments.length}',
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.onRefresh != null)
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.grey[400], size: 20),
                  onPressed: widget.isLoading ? null : widget.onRefresh,
                ),
            ],
          ),
        ),
        if (_replyingTo != null) _buildReplyIndicator(),
        if (widget.isStudent) _buildCommentInput(),
        const SizedBox(height: 12),
        if (widget.isLoading)
          _buildLoadingState()
        else if (widget.comments.isEmpty)
          _buildEmptyState()
        else
          _buildCommentsList(),
      ],
    );
  }

  Widget _buildReplyIndicator() {
    final parentComment = widget.comments.firstWhere(
      (c) => c.id == _replyingTo,
      orElse: () => widget.comments.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16, color: Color(0xFF6C63FF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đang trả lời ${parentComment.userName}',
              style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _replyingTo = null),
            child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildCommentInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Viết bình luận của bạn...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _isPosting ? null : _handleSubmit,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _topLevelComments.asMap().entries.map((entry) {
          final index = entry.key;
          final comment = entry.value;
          final replies = _getReplies(comment.id);
          final isTeacher = comment.userId == widget.teacherId;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommentCard(
                    comment: comment,
                    isTeacher: isTeacher,
                    onReply: widget.isStudent
                        ? () => setState(() => _replyingTo = comment.id)
                        : null,
                  )
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn()
                  .slideY(begin: 0.1),
              ...replies.map((reply) {
                final isReplyTeacher = reply.userId == widget.teacherId;
                return CommentCard(
                  comment: reply,
                  isTeacher: isReplyTeacher,
                  isReply: true,
                  depth: 1,
                  onReply: widget.isStudent
                      ? () => setState(() => _replyingTo = reply.id)
                      : null,
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Chưa có bình luận nào',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            if (widget.isStudent) ...[
              const SizedBox(height: 4),
              Text(
                'Hãy là người đầu tiên bình luận!',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
