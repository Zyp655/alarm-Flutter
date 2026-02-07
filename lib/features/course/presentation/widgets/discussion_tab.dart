import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';

class DiscussionTab extends StatefulWidget {
  final int lessonId;
  final int userId; 

  const DiscussionTab({
    super.key,
    required this.lessonId,
    required this.userId,
  });

  @override
  State<DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends State<DiscussionTab> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(LoadCommentsEvent(widget.lessonId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Đặt câu hỏi hoặc bình luận...',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final content = _commentController.text.trim();
                  if (content.isNotEmpty) {
                    context.read<CommentBloc>().add(
                      AddCommentEvent(
                        lessonId: widget.lessonId,
                        userId: widget.userId,
                        content: content,
                      ),
                    );
                    _commentController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
                icon: const Icon(Icons.send, color: Colors.blueAccent),
              ),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CommentError) {
                return Center(child: Text('Lỗi: ${state.message}'));
              } else if (state is CommentLoaded) {
                if (state.comments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('Chưa có thảo luận nào. Hãy là người đầu tiên!'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: comment.isTeacherResponse
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            child: Text(
                              comment.userName[0].toUpperCase(),
                              style: TextStyle(
                                color: comment.isTeacherResponse
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: comment.isTeacherResponse
                                            ? Colors.blueAccent
                                            : null,
                                      ),
                                    ),
                                    if (comment.isTeacherResponse) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Colors.blueAccent,
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(
                                      timeago.format(comment.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
