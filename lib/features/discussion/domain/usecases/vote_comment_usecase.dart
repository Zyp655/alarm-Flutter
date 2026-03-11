import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/discussion_repository.dart';

class VoteCommentUseCase {
  final DiscussionRepository repository;

  VoteCommentUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required int commentId,
    required int userId,
    required String voteType,
  }) {
    return repository.vote(
      commentId: commentId,
      userId: userId,
      voteType: voteType,
    );
  }
}
