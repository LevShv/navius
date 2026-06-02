import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDataSource dataSource;
  
  SearchRepositoryImpl({required this.dataSource});
  
  @override
  Future<List<SearchResult>> search(String query) async {
    try {
      final models = await dataSource.search(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('Repository search error: $e');
      return [];
    }
  }
}