import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/route_progress.dart';

class MapState extends Equatable {
    final Location? currentLocation;
    final bool isLoading;
    final bool isRouteLoading;
    final String? error;
    final bool forceCenter;
    final bool isTracking;
    final RouteInfo? currentRoute;
    final int? currentSegmentIndex;
    final Location? projectedLocation;
    final bool isRouteCompleted;
    final Location? destination;
    final bool isRerouting;
    final RouteProgress? routeProgress;
    final DateTime? routeStartTime; 
    final double savedProgressPercent;
    final bool showRouitingUi;

    const MapState({
        this.currentLocation,
        this.isLoading = false,
        this.isRouteLoading = false,
        this.error,
        this.forceCenter = true,
        this.isTracking = false,
        this.currentRoute,
        this.currentSegmentIndex = 0,
        this.projectedLocation,
        this.isRouteCompleted = false,
        this.destination,
        this.isRerouting = false,
        this.routeProgress,
        this.routeStartTime,
        this.savedProgressPercent = 0.0,
        this.showRouitingUi = false,
    });

    MapState copyWith({
        Location? currentLocation,
        bool? isLoading,
        bool? isRouteLoading,
        String? error,
        bool? forceCenter,
        bool? isTracking,
        RouteInfo? currentRoute,
        int? currentSegmentIndex,
        Location? projectedLocation,
        bool? isRouteCompleted,
        Location? destination,
        bool? isRerouting,
        RouteProgress? routeProgress,
        DateTime? routeStartTime, 
        double? savedProgressPercent,
        bool? showRouitingUi,
        
    }) {
        return MapState(
            currentLocation: currentLocation ?? this.currentLocation,
            isLoading: isLoading ?? this.isLoading,
            isRouteLoading: isRouteLoading ?? this.isRouteLoading,
            error: error ?? this.error,
            forceCenter: forceCenter ?? this.forceCenter,
            isTracking: isTracking ?? this.isTracking,
            currentRoute: currentRoute ?? this.currentRoute,
            currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
            projectedLocation: projectedLocation ?? this.projectedLocation,
            isRouteCompleted: isRouteCompleted ?? this.isRouteCompleted,
            destination: destination ?? this.destination,
            isRerouting: isRerouting ?? this.isRerouting,
            routeProgress: routeProgress ?? this.routeProgress,
            routeStartTime: routeStartTime ?? this.routeStartTime,
            savedProgressPercent: savedProgressPercent ?? this.savedProgressPercent,
            showRouitingUi: showRouitingUi ?? this.showRouitingUi,
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
      routeProgress,
      routeStartTime,
      savedProgressPercent, 
      showRouitingUi,
      isRouteLoading
    ];
}
