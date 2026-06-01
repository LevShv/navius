/*import 'dart:convert';
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
}*/

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RouteDataSource {
 
  final String baseUrl = 'http://llvvv.ru:8081';  

  final http.Client client;

  RouteDataSource({http.Client? client}) : client = client ?? http.Client();

   Future<Map<String, dynamic>> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'ebike',  
  }) async {
    final url = Uri.parse(
      '$baseUrl/route'
      '?point=$startLat,$startLng'
      '&point=$endLat,$endLng'
      '&profile=$profile'
      '&locale=ru'  
      '&instructions=true'
      '&points_encoded=false'
      '&calc_points=true'
    );

    print('Request: $url');

    try {
      final response = await client.get(url);

      if (response.statusCode != 200) {
        print('Error: ${response.body}');
        throw Exception('Failed to get route: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      
      if (data['paths'] == null || data['paths'].isEmpty) {
        throw Exception('No routes found');
      }
      
      return data;
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}