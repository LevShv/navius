import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RouteDataSource {
  final String baseUrl = 'https://router.project-osrm.org';

  final http.Client client;

  RouteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {

    final url = Uri.parse(
      '$baseUrl/route/v1/driving/$startLng,$startLat;$endLng,$endLat'
      '?overview=full&geometries=geojson&steps=true'
    );

    final response = await client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to get route: ${response.statusCode}');
    }
    return json.decode(response.body);
  }
}