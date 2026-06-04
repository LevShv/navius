import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_model.dart';

abstract class SearchDataSource {
  Future<List<SearchResultModel>> search(String query);
}

class SearchDataSourceImpl implements SearchDataSource {
  final http.Client client;
  
  SearchDataSourceImpl({required this.client});
  
  @override
  Future<List<SearchResultModel>> search(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }
    
    final url = 'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=10'
        '&addressdetails=1'
        '&accept-language=ru';
    
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'NaviusApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SearchResultModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
}