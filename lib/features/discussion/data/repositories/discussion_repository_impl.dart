import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/discussion_comment.dart';
import '../../domain/repositories/discussion_repository.dart';
import '../datasources/discussion_remote_datasource.dart';
import '../services/discussion_ws_service.dart';

class DiscussionRepositoryImpl implements DiscussionRepository {
  final DiscussionRemoteDataSource remoteDataSource;
  final DiscussionWsService wsService;

  DiscussionRepositoryImpl({
    required this.remoteDataSource,
    required this.wsService,
  });

  @override
  Future<Either<Failure, List<DiscussionComment>>> getDiscussions({
    required int lessonId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final comments = await remoteDataSource.getDiscussions(
        lessonId: lessonId,
        page: page,
        limit: limit,
      );
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure('Failed to load discussions: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createComment({
    required int lessonId,
    required int userId,
    required String text,
    int? parentId,
  }) async {
    try {
      final id = await remoteDataSource.createComment(
        lessonId: lessonId,
        userId: userId,
        text: text,
        parentId: parentId,
      );
      return Right(id);
    } catch (e) {
      return Left(ServerFailure('Failed to create comment: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> vote({
    required int commentId,
    required int userId,
    required String voteType,
  }) async {
    try {
      final action = await remoteDataSource.vote(
        commentId: commentId,
        userId: userId,
        voteType: voteType,
      );
      return Right(action);
    } catch (e) {
      return Left(ServerFailure('Failed to vote: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> moderate({
    required int commentId,
    required String action,
  }) async {
    try {
      await remoteDataSource.moderate(commentId: commentId, action: action);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to moderate: $e'));
    }
  }

  @override
  Stream<Map<String, dynamic>> connectToLessonRoom(int lessonId) {
    wsService.connect(lessonId);
    return wsService.eventStream;
  }

  @override
  void disconnectFromLessonRoom() {
    wsService.disconnect();
  }
}
