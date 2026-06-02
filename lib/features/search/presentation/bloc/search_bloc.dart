import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/search_places.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchPlaces searchPlaces;
  
  SearchBloc({required this.searchPlaces}) : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<ClearSearch>(_onClearSearch);
  }
  
  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty || event.query.length < 2) {
      emit(state.copyWith(results: [], isSearching: false, error: null));
      return;
    }
    
    emit(state.copyWith(isLoading: true, isSearching: true, error: null));
    
    try {
      final results = await searchPlaces.execute(event.query);
      emit(state.copyWith(
        results: results,
        isLoading: false,
        isSearching: results.isNotEmpty,
        error: results.isEmpty ? 'Ничего не найдено' : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        results: [],
        isLoading: false,
        isSearching: false,
        error: 'Ошибка поиска. Попробуйте позже.',
      ));
    }
  }
  
  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(results: [], isSearching: false, error: null));
  }
  
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}