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

  Location toLocation() => Location(
    latitude: latitude,
    longitude: longitude,
  );

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

  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} км';
    }
    return '${distance.round()} м';
  }

  String get formattedDuration {
    final hours = Duration(seconds: duration).inHours;
    final minutes = Duration(seconds: duration).inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours ч $minutes мин';
    }
    return '$minutes мин';
  }

  DateTime getEstimatedArrivalTime({required DateTime startTime}) {
    return startTime.add(Duration(seconds: duration));
  }
  
  @override
  List<Object?> get props => [points, distance, duration, summary];
}

