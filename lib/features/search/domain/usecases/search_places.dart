import '../repositories/search_repository.dart';
import '../entities/search_result.dart';

class SearchPlaces {
  final SearchRepository repository;
  
  SearchPlaces(this.repository);
  
  Future<List<SearchResult>> execute(String query) {
    if (query.isEmpty || query.length < 2) {
      return Future.value([]);
    }
    return repository.search(query);
  }
}