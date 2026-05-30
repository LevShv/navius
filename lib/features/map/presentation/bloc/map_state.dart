import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';

class MapState extends Equatable {
    final Location? currentLocation;
    final bool isLoading;
    final String? error;
    final bool forceCenter;
    final bool isTracking;

    const MapState({
        this.currentLocation,
        this.isLoading = false,
        this.error,
        this.forceCenter = false,
        this.isTracking = false,
    });

    MapState copyWith({
        Location? currentLocation,
        bool? isLoading,
        String? error,
        bool? forceCenter,
        bool? isTracking,
    }) {
        return MapState(
            currentLocation: currentLocation ?? this.currentLocation,
            isLoading: isLoading ?? this.isLoading,
            error: error ?? this.error,
            forceCenter: forceCenter ?? false,
            isTracking: isTracking ?? this.isTracking,
        );
    }

    @override
    List<Object?> get props => [
      currentLocation, 
      isLoading, 
      error, 
      forceCenter,
      isTracking
    ];
}
