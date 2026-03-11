import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/discussion_repository.dart';

class ModerateCommentUseCase {
  final DiscussionRepository repository;

  ModerateCommentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int commentId,
    required String action,
  }) {
    return repository.moderate(commentId: commentId, action: action);
  }
}
