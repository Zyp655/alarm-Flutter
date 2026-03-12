import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;

  SearchUseCase(this.repository);

  Future<Either<Failure, List<SearchResult>>> call(SearchParams params) {
    return repository.search(
      query: params.query,
      type: params.type,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchParams extends Equatable {
  final String query;
  final String? type;
  final int page;
  final int limit;

  const SearchParams({
    required this.query,
    this.type,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, type, page, limit];
}
