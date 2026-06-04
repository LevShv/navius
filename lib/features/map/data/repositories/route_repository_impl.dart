import '../../domain/entities/location.dart';
import '../../domain/entities/route.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/route_datasource.dart';

class RouteRepositoryImpl implements RouteRepository{
  final RouteDataSource dataSource;

  RouteRepositoryImpl(this.dataSource);

  @override 
  Future<RouteInfo> getRoute({
    required Location start,
    required Location end,
  }) async {
    try {
      final rawData = await dataSource.fetchRoute(
        startLat: start.latitude,
        startLng: start.longitude,
        endLat: end.latitude,
        endLng: end.longitude,
      );

      if (rawData['routes'] == null || rawData['routes'].isEmpty) {
        throw Exception('Маршрут не найден');
      }
      
      final route = rawData['routes'][0];
      final geometry = route['geometry']['coordinates'];
      
      final points = _parseCoordinates(geometry);
      
      return RouteInfo(
        points: points,
        distance: route['distance']?.toDouble() ?? 0.0,
        duration: route['duration']?.toInt() ?? 0,
        summary: route['summary'] ?? 'Маршрут построен',
       );
    
    } catch (e) {
      throw Exception('Ошибка построения маршрута: $e');
    }
  }

  List<RoutePoint> _parseCoordinates(List<dynamic> coordinates) {
    return coordinates.map<RoutePoint>((coord) {
      return RoutePoint(
        longitude: coord[0].toDouble(),
        latitude: coord[1].toDouble(),
      );
    }).toList();
  }
}
