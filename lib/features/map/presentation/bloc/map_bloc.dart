import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navius/features/map/domain/usecases/get_location_stream.dart';
import 'package:navius/features/map/domain/entities/location.dart';
import 'dart:async';
import 'map_event.dart';
import 'map_state.dart';
import '../../domain/usecases/get_current_location.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;
  final GetLocationStream getLocationStream;
  StreamSubscription<Location>? _locationSubscription;

  MapBloc({
    required this.getCurrentLocation,
    required this.getLocationStream,
  }) : super(const MapState()) {
      on<LoadLocation>(_onLoadLocation);
      on<CenterOnUser>(_onCenterOnUser);
      on<ResetForceCenter>(_onResetForceCenter);
      on<StartLocationTracking>(_onStartLocationTracking);
      on<StopLocationTracking>(_onStopLocationTracking);
      on<LocationUpdated>(_onLocationUpdated);

  }

  Future<void> _onLoadLocation(
    LoadLocation event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final location = await getCurrentLocation();
      emit(state.copyWith(
          currentLocation: location,
          isLoading: false,
          error: null,
      ));
    
      add(StartLocationTracking());
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }  

  void _onCenterOnUser(
    CenterOnUser event,
    Emitter<MapState> emit,
  ) async {
    try {
      final location = await getCurrentLocation();

      emit(state.copyWith(
        currentLocation: location,
        isLoading: false,
        forceCenter: true,
        error: null,
      ));
    } catch (e){
      print("CenterOnUser state error: $e");
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }    

  void _onResetForceCenter(
    ResetForceCenter event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(forceCenter: false));
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<MapState> emit,
  ) async {
    if (state.isTracking) return;

    emit(state.copyWith(isTracking: true));

    _locationSubscription = getLocationStream().listen(
      (location) {
        print('📍 Новая позиция: ${location.latitude}, ${location.longitude}');
        add(LocationUpdated(location));
      },
      onError: (error) {
        print('Ошибка отслеживания: $error');
        add(StopLocationTracking());
      }
    );
  }

  void _onStopLocationTracking(
    StopLocationTracking event,
    Emitter<MapState> emit,
  ) {
    _locationSubscription?.cancel();
    emit(state.copyWith(isTracking: false));
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      currentLocation: event.location,
    ));
  }
}