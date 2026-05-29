import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';

class MapState extends Equatable {
    final Location? currentLocation;
    final bool isLoading;
    final String? error;

    const MapState({
        this.currentLocation,
        this.isLoading = false,
        this.error,
    });

    MapState copyWith({
        Location? currentLocation,
        bool? isLoading,
        String? error,
    }) {
        return MapState(
            currentLocation: currentLocation ?? this.currentLocation,
            isLoading: isLoading ?? this.isLoading,
            error: error ?? this.error,
        );
    }

    @override
    List<Object?> get props => [currentLocation, isLoading, error];
}
