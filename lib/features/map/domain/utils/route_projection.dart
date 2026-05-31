import '../entities/location.dart';
import '../entities/route.dart';

class RouteProjection {
  final int segmentIndex;
  final Location projectedPoint;

  const RouteProjection({
    required this.segmentIndex,
    required this.projectedPoint,
  });

  static RouteProjection projectOnRoute(
    Location user,
    List<RoutePoint> routePoints,
  ) {
    double bestDistance = double.infinity;

    int bestSegment = 0;

    Location? bestProjection;

    for (int i = 0; i < routePoints.length - 1; i++) {
      final projection = _projectPointToSegment(
        user,
        routePoints[i],
        routePoints[i + 1],
      );

      final distance = _distanceSquared(
        user,
        projection,
      );

      if (distance < bestDistance) {
        bestDistance = distance;
        bestSegment = i;
        bestProjection = projection;
      }
    }

    return RouteProjection(
      segmentIndex: bestSegment,
      projectedPoint: bestProjection!,
    );
  }

  static double _distanceSquared(
    Location a,
    Location b,
  ) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;

    return dx * dx + dy * dy;
  }

  static Location _projectPointToSegment(
    Location p,
    RoutePoint a,
    RoutePoint b,
  ) {
    final ax = a.longitude;
    final ay = a.latitude;

    final bx = b.longitude;
    final by = b.latitude;

    final px = p.longitude;
    final py = p.latitude;

    final abx = bx - ax;
    final aby = by - ay;

    final apx = px - ax;
    final apy = py - ay;

    final ab2 = abx * abx + aby * aby;

    if (ab2 == 0) {
      return Location(
        latitude: a.latitude,
        longitude: a.longitude,
      );
    }

    double t = (apx * abx + apy * aby) / ab2;

    t = t.clamp(0.0, 1.0);

    return Location(
      latitude: ay + aby * t,
      longitude: ax + abx * t,
    );
  }
}