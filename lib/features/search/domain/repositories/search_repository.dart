import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResult>>> search({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  });
}
