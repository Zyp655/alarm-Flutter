import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchFilterChanged extends SearchEvent {
  final SearchResultType? filter;
  const SearchFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

class SaveSearchQuery extends SearchEvent {
  final String query;
  const SaveSearchQuery(this.query);
  @override
  List<Object?> get props => [query];
}

class RemoveHistoryItem extends SearchEvent {
  final String query;
  const RemoveHistoryItem(this.query);
  @override
  List<Object?> get props => [query];
}

class ClearSearchHistory extends SearchEvent {
  const ClearSearchHistory();
}
