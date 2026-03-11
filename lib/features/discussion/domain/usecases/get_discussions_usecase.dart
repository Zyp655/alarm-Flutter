import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discussion_comment.dart';
import '../repositories/discussion_repository.dart';

class GetDiscussionsUseCase {
  final DiscussionRepository repository;

  GetDiscussionsUseCase(this.repository);

  Future<Either<Failure, List<DiscussionComment>>> call({
    required int lessonId,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getDiscussions(
      lessonId: lessonId,
      page: page,
      limit: limit,
    );
  }
}
