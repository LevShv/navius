import '../../domain/entities/search_result.dart';

class SearchResultModel {
  final String placeId;
  final String displayName;
  final String lat;
  final String lon;
  
  SearchResultModel({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
  });
  
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '0',
      lon: json['lon'] ?? '0',
    );
  }
  
  SearchResult toEntity() {
    return SearchResult(
      id: placeId,
      name: _extractName(displayName),
      address: displayName,
      latitude: double.parse(lat),
      longitude: double.parse(lon),
    );
  }
  
  String _extractName(String fullName) {
    final parts = fullName.split(',');
    return parts.isNotEmpty ? parts[0].trim() : fullName;
  }
}