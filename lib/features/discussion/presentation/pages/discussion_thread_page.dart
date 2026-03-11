import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/discussion_bloc.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_composer.dart';
import '../widgets/discussion_empty_state.dart';
import '../../../../core/theme/app_colors.dart';

class DiscussionThreadPage extends StatefulWidget {
  final int lessonId;
  final int userId;
  final String lessonTitle;
  final bool embedded;

  const DiscussionThreadPage({
    super.key,
    required this.lessonId,
    required this.userId,
    required this.lessonTitle,
    this.embedded = false,
  });

  @override
  State<DiscussionThreadPage> createState() => _DiscussionThreadPageState();
}

class _DiscussionThreadPageState extends State<DiscussionThreadPage> {
  final _textController = TextEditingController();
  int? _replyingTo;

  @override
  void initState() {
    super.initState();
    context.read<DiscussionBloc>().add(
      LoadDiscussions(lessonId: widget.lessonId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final body = Column(
      children: [
        Expanded(
          child: BlocConsumer<DiscussionBloc, DiscussionState>(
            listener: (context, state) {
              if (state is CommentPosted) {
                _textController.clear();
                _replyingTo = null;
              }
            },
            builder: (context, state) {
              if (state is DiscussionLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is DiscussionLoaded) {
                if (state.comments.isEmpty) {
                  return DiscussionEmptyState(isDark: isDark);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) => CommentCard(
                    comment: state.comments[index],
                    isDark: isDark,
                    isRoot: true,
                    currentUserId: widget.userId,
                    onReply: () {
                      setState(() => _replyingTo = state.comments[index].id);
                    },
                  ),
                );
              }
              if (state is DiscussionError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        CommentComposer(
          textController: _textController,
          isDark: isDark,
          isReplying: _replyingTo != null,
          onCancelReply: () => setState(() => _replyingTo = null),
          onSend: () {
            if (_textController.text.trim().isNotEmpty) {
              context.read<DiscussionBloc>().add(
                PostComment(
                  lessonId: widget.lessonId,
                  userId: widget.userId,
                  text: _textController.text.trim(),
                  parentId: _replyingTo,
                ),
              );
            }
          },
        ),
      ],
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          '💬 ${widget.lessonTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
