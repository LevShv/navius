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
      on<LocationUpdated>(_onLocationUpdated);

      add(LoadLocation());
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
          isTracking: true,
      ));
    
      _startTracking();
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        isTracking: false,
      ));
      _startTracking();
    }
  }  

  void _startTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = getLocationStream().listen(
      (location) {
        print('📍 Новая позиция: ${location.latitude}, ${location.longitude}');
        add(LocationUpdated(location));
      },
      onError: (error) {
        print('Ошибка отслеживания: $error');
       
        Future.delayed(const Duration(seconds: 5), () {
          if (!isClosed) {
            _startTracking();
          }
        });
      },
    );
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

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      currentLocation: event.location,
    ));
  }
}