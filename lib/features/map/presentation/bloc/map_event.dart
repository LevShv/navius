import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';

abstract class MapEvent extends Equatable{
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadLocation extends MapEvent {}
class CenterOnUser extends MapEvent {}
class ResetForceCenter extends MapEvent {}

class StartLocationTracking extends MapEvent {}
class StopLocationTracking extends MapEvent {}
class LocationUpdated extends MapEvent {
  final Location location;
  LocationUpdated(this.location);
}

class BuildRoute extends MapEvent {
  final Location destination;
  const BuildRoute(this.destination);
}

class ClearRoute extends MapEvent {}

class UpdateRouteProgress extends MapEvent {
  final Location currentLocation;
  const UpdateRouteProgress(this.currentLocation);
}