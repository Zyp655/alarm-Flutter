import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/discussion_repository.dart';

class PostCommentUseCase {
  final DiscussionRepository repository;

  PostCommentUseCase(this.repository);

  Future<Either<Failure, int>> call({
    required int lessonId,
    required int userId,
    required String text,
    int? parentId,
  }) {
    return repository.createComment(
      lessonId: lessonId,
      userId: userId,
      text: text,
      parentId: parentId,
    );
  }
}
