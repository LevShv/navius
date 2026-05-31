import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/route.dart';

class MapState extends Equatable {
    final Location? currentLocation;
    final bool isLoading;
    final String? error;
    final bool forceCenter;
    final bool isTracking;
    final RouteInfo? currentRoute;
    final int? currentSegmentIndex;
    final Location? projectedLocation;
    final bool isRouteCompleted;
    final Location? destination;
    final bool isRerouting;

    const MapState({
        this.currentLocation,
        this.isLoading = false,
        this.error,
        this.forceCenter = false,
        this.isTracking = false,
        this.currentRoute,
        this.currentSegmentIndex = 0,
        this.projectedLocation,
        this.isRouteCompleted = false,
        this.destination,
        this.isRerouting = false,

    });

    MapState copyWith({
        Location? currentLocation,
        bool? isLoading,
        String? error,
        bool? forceCenter,
        bool? isTracking,
        RouteInfo? currentRoute,
        int? currentSegmentIndex,
        Location? projectedLocation,
        bool? isRouteCompleted,
        Location? destination,
        bool? isRerouting,
        
    }) {
        return MapState(
            currentLocation: currentLocation ?? this.currentLocation,
            isLoading: isLoading ?? this.isLoading,
            error: error ?? this.error,
            forceCenter: forceCenter ?? false,
            isTracking: isTracking ?? this.isTracking,
            currentRoute: currentRoute ?? this.currentRoute,
            currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
            projectedLocation: projectedLocation ?? this.projectedLocation,
            isRouteCompleted: isRouteCompleted ?? this.isRouteCompleted,
            destination: destination ?? this.destination,
            isRerouting: isRerouting ?? this.isRerouting,

        );
    }

    @override
    List<Object?> get props => [
      currentLocation, 
      isLoading, 
      error, 
      forceCenter,
      isTracking,
      currentRoute,
      currentSegmentIndex,
      projectedLocation,
      isRouteCompleted,
      destination,
      isRerouting,
    ];
}
