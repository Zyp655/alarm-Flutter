import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discussion_comment.dart';

abstract class DiscussionRepository {
  
  Future<Either<Failure, List<DiscussionComment>>> getDiscussions({
    required int lessonId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, int>> createComment({
    required int lessonId,
    required int userId,
    required String text,
    int? parentId,
  });

  Future<Either<Failure, String>> vote({
    required int commentId,
    required int userId,
    required String voteType,
  });

  Future<Either<Failure, void>> moderate({
    required int commentId,
    required String action,
  });

  Stream<Map<String, dynamic>> connectToLessonRoom(int lessonId);

  void disconnectFromLessonRoom();
}
