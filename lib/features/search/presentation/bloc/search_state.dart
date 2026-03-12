import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> searchHistory;

  const SearchInitial({this.searchHistory = const []});

  @override
  List<Object?> get props => [searchHistory];
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final String query;
  final SearchResultType? activeFilter;

  const SearchLoaded({
    required this.results,
    required this.query,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [results, query, activeFilter];
}

class SearchEmpty extends SearchState {
  final String query;
  const SearchEmpty(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchSuggestions extends SearchState {
  final List<String> suggestions;
  final String query;

  const SearchSuggestions({required this.suggestions, required this.query});

  @override
  List<Object?> get props => [suggestions, query];
}
