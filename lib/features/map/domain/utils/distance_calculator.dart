import 'dart:math' as math;
import '../entities/location.dart';
import '../entities/route.dart';

class DistanceCalculator {
  static const double earthRadius = 6371000;
  
  static double between(Location loc1, RoutePoint loc2) {
    final dLat = _toRadians(loc2.latitude - loc1.latitude);
    final dLon = _toRadians(loc2.longitude - loc1.longitude);
    
    final a = 
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(loc1.latitude)) * 
      math.cos(_toRadians(loc2.latitude)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
  
  static double betweenLocations(Location loc1, Location loc2) {
    final dLat = _toRadians(loc2.latitude - loc1.latitude);
    final dLon = _toRadians(loc2.longitude - loc1.longitude);
    
    final a = 
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(loc1.latitude)) * 
      math.cos(_toRadians(loc2.latitude)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
  
  static double _toRadians(double degrees) => degrees * math.pi / 180;
}