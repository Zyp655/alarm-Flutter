import '../../../../core/api/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchResultModel>> search({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient client;

  SearchRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SearchResultModel>> search({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final typeParam = type != null ? '&type=$type' : '';
      final response = await client.get(
        '/search?q=${Uri.encodeComponent(query)}$typeParam&page=$page&limit=$limit',
      );

      final data = response as Map<String, dynamic>;
      final rawResults = data['results'] as List<dynamic>? ?? [];

      return rawResults
          .map(
            (json) => SearchResultModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Lỗi tìm kiếm: $e');
    }
  }
}
