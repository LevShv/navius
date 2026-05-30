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

    const MapState({
        this.currentLocation,
        this.isLoading = false,
        this.error,
        this.forceCenter = false,
        this.isTracking = false,
        this.currentRoute,
    });

    MapState copyWith({
        Location? currentLocation,
        bool? isLoading,
        String? error,
        bool? forceCenter,
        bool? isTracking,
        RouteInfo? currentRoute,
    }) {
        return MapState(
            currentLocation: currentLocation ?? this.currentLocation,
            isLoading: isLoading ?? this.isLoading,
            error: error ?? this.error,
            forceCenter: forceCenter ?? false,
            isTracking: isTracking ?? this.isTracking,
            currentRoute: currentRoute ?? this.currentRoute,
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
    ];
}
