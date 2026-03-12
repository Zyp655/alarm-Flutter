import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

export 'search_event.dart';
export 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase searchUseCase;
  final SharedPreferences prefs;

  Timer? _debounce;
  String _lastQuery = '';
  SearchResultType? _activeFilter;

  static const _historyKey = 'search_history';
  static const _maxHistory = 10;

  SearchBloc({required this.searchUseCase, required this.prefs})
    : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    on<ClearSearch>(_onClear);
    on<LoadSearchHistory>(_onLoadHistory);
    on<SaveSearchQuery>(_onSaveQuery);
    on<RemoveHistoryItem>(_onRemoveHistoryItem);
    on<ClearSearchHistory>(_onClearHistory);
  }

  List<String> _getHistory() {
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> _saveHistory(List<String> history) async {
    await prefs.setStringList(_historyKey, history);
  }

  void _onLoadHistory(LoadSearchHistory event, Emitter<SearchState> emit) {
    emit(SearchInitial(searchHistory: _getHistory()));
  }

  Future<void> _onSaveQuery(
    SaveSearchQuery event,
    Emitter<SearchState> emit,
  ) async {
    final q = event.query.trim();
    if (q.isEmpty) return;

    final history = _getHistory();
    history.remove(q);
    history.insert(0, q);
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }
    await _saveHistory(history);
  }

  Future<void> _onRemoveHistoryItem(
    RemoveHistoryItem event,
    Emitter<SearchState> emit,
  ) async {
    final history = _getHistory();
    history.remove(event.query);
    await _saveHistory(history);
    emit(SearchInitial(searchHistory: history));
  }

  Future<void> _onClearHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    await prefs.remove(_historyKey);
    emit(const SearchInitial());
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _lastQuery = event.query.trim();

    if (_lastQuery.isEmpty) {
      emit(SearchInitial(searchHistory: _getHistory()));
      return;
    }

    if (_lastQuery.length < 3) {
      final history = _getHistory();
      final suggestions = history
          .where((h) => h.toLowerCase().contains(_lastQuery.toLowerCase()))
          .toList();
      if (suggestions.isNotEmpty) {
        emit(SearchSuggestions(suggestions: suggestions, query: _lastQuery));
      }
    }

    emit(SearchLoading());
    _debounce?.cancel();
    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      completer.complete();
    });
    await completer.future;

    await _performSearch(emit);
  }

  void _onFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    _activeFilter = event.filter;

    if (_lastQuery.isEmpty) {
      emit(SearchInitial(searchHistory: _getHistory()));
      return;
    }

    emit(SearchLoading());
    await _performSearch(emit);
  }

  void _onClear(ClearSearch event, Emitter<SearchState> emit) {
    _lastQuery = '';
    _activeFilter = null;
    emit(SearchInitial(searchHistory: _getHistory()));
  }

  Future<void> _performSearch(Emitter<SearchState> emit) async {
    final result = await searchUseCase(
      SearchParams(query: _lastQuery, type: _activeFilter?.name),
    );

    result.fold((failure) => emit(SearchError(failure.message)), (results) {
      add(SaveSearchQuery(_lastQuery));

      if (results.isEmpty) {
        emit(SearchEmpty(_lastQuery));
      } else {
        emit(
          SearchLoaded(
            results: results,
            query: _lastQuery,
            activeFilter: _activeFilter,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
