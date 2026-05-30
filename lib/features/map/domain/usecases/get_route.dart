import 'package:flutter/widgets.dart';

import '../repositories/route_repository.dart';
import '../entities/location.dart';
import '../entities/route.dart';

class GetRoute {
  final RouteRepository repository;

  GetRoute(this.repository);

  Future<RouteInfo> call({
    required Location start,
    required Location end,
  }) async {
    if (start.latitude == end.latitude && start.longitude == end.longitude) {
      throw Exception('Начальная и конечная точки совпадают');
    }
    return await repository.getRoute(start: start, end: end);
  }
}