import '../entities/location.dart';
import '../entities/route.dart';

abstract class RouteRepository {
  Future<RouteInfo> getRoute({
    required Location start,
    required Location end,
  });
}