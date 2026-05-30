import 'package:equatable/equatable.dart';
import 'location.dart';

class RoutePoint extends Equatable {
  final double latitude;
  final double longitude;
  final int? index;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.index,
  });

  @override
  List<Object?> get props => [latitude, longitude, index];
}

class RouteInfo extends Equatable {
  final List<RoutePoint> points;
  final double distance;
  final int duration;
  final String summary;

  const RouteInfo({
    required this.points,
    required this.distance,
    required this.duration,
    required this.summary,
  });

  @override
  List<Object?> get props => [points, distance, duration, summary];
}

class NavigationStep extends Equatable {
  final String instruction; 
  final double distance; 
  final int duration; 
  final RoutePoint point;
  
  const NavigationStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.point,
  });
  
  @override
  List<Object?> get props => [instruction, distance, duration, point];
}