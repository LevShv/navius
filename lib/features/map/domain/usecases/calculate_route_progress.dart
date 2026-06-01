import '../entities/location.dart';
import '../entities/route.dart';
import '../entities/route_progress.dart';
import '../utils/distance_calculator.dart';

class CalculateRouteProgress {
  static const double defaultSpeedMps = 5.56; // 20 км/ч
  
  RouteProgress execute({
    required RouteInfo route,
    required Location currentLocation,
    required int currentSegmentIndex,
    required Location projectedLocation,
    required DateTime routeStartTime,
  }) {
    final remainingDistance = _calculateRemainingDistance(
      route: route,
      currentSegmentIndex: currentSegmentIndex,
      projectedLocation: projectedLocation,
    );
    
    final progressPercent = 1.0 - (remainingDistance / route.distance);
    final remainingDuration = (remainingDistance / defaultSpeedMps).round();   
    final eta = DateTime.now().add(Duration(seconds: remainingDuration));
    
    return RouteProgress(
      remainingDistance: remainingDistance,
      remainingDuration: remainingDuration,
      eta: eta,
      progressPercent: progressPercent.clamp(0.0, 1.0),
    );
  }
  
  double _calculateRemainingDistance({
    required RouteInfo route,
    required int currentSegmentIndex,
    required Location projectedLocation,
  }) {
    double remainingDistance = 0.0;
    
    if (currentSegmentIndex < route.points.length - 1) {
      final currentPoint = route.points[currentSegmentIndex];
      final nextPoint = route.points[currentSegmentIndex + 1];
      
      remainingDistance += DistanceCalculator.betweenLocations(
        projectedLocation,
        Location(
          latitude: nextPoint.latitude,
          longitude: nextPoint.longitude,
        ),
      );
    }
    
    for (int i = currentSegmentIndex + 1; i < route.points.length - 1; i++) {
      final point1 = route.points[i];
      final point2 = route.points[i + 1];
      
      remainingDistance += DistanceCalculator.betweenLocations(
        Location(latitude: point1.latitude, longitude: point1.longitude),
        Location(latitude: point2.latitude, longitude: point2.longitude),
      );
    }
    
    return remainingDistance;
  }
}