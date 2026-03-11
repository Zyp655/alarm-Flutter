import '../../../../core/api/api_client.dart';
import '../models/discussion_comment_model.dart';

abstract class DiscussionRemoteDataSource {
  Future<List<DiscussionCommentModel>> getDiscussions({
    required int lessonId,
    int page = 1,
    int limit = 20,
  });

  Future<int> createComment({
    required int lessonId,
    required int userId,
    required String text,
    int? parentId,
  });

  Future<String> vote({
    required int commentId,
    required int userId,
    required String voteType,
  });

  Future<void> moderate({required int commentId, required String action});
}

class DiscussionRemoteDataSourceImpl implements DiscussionRemoteDataSource {
  final ApiClient apiClient;

  DiscussionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DiscussionCommentModel>> getDiscussions({
    required int lessonId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.get(
      '/discussions?lessonId=$lessonId&page=$page&limit=$limit',
    );

    final discussions = response['discussions'] as List<dynamic>? ?? [];
    return discussions
        .map(
          (json) =>
              DiscussionCommentModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<int> createComment({
    required int lessonId,
    required int userId,
    required String text,
    int? parentId,
  }) async {
    final response = await apiClient.post('/discussions', {
      'lessonId': lessonId,
      'userId': userId,
      'content': text,
      if (parentId != null) 'parentId': parentId,
    });
    return response['id'] as int;
  }

  @override
  Future<String> vote({
    required int commentId,
    required int userId,
    required String voteType,
  }) async {
    final response = await apiClient.post('/discussions/vote', {
      'commentId': commentId,
      'userId': userId,
      'voteType': voteType,
    });
    return response['action'] as String? ?? 'voted';
  }

  @override
  Future<void> moderate({
    required int commentId,
    required String action,
  }) async {
    await apiClient.post('/discussions/moderate', {
      'commentId': commentId,
      'action': action,
    });
  }
}
