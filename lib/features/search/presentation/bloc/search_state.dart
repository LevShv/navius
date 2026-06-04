import '../../domain/entities/search_result.dart';

class SearchState {
  final List<SearchResult> results;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  
  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.error,
  });
  
  SearchState copyWith({
    List<SearchResult>? results,
    bool? isLoading,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
    );
  }
}