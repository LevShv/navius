import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:navius/features/map/domain/usecases/get_location_stream.dart';
import 'package:navius/features/map/domain/entities/location.dart';
import 'dart:async';
import 'map_event.dart';
import 'map_state.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_route.dart';
import '../../domain/utils/route_projection.dart';
import '../../domain/utils/distance_calculator.dart' as calc;

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;
  final GetLocationStream getLocationStream;
  StreamSubscription<Location>? _locationSubscription;
  final GetRoute getRoute;

  MapBloc({
    required this.getCurrentLocation,
    required this.getLocationStream,
    required this.getRoute,
  }) : super(const MapState()) {
      on<LoadLocation>(_onLoadLocation);
      on<CenterOnUser>(_onCenterOnUser);
      on<LocationUpdated>(_onLocationUpdated);
      on<BuildRoute>(_onBuildRoute);
      on<ClearRoute>(_onClearRoute);
      on<ResetForceCenter>(_onResetForceCenter);
      on<UpdateRouteProgress>(_onUpdateRouteProgress);


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

  Future<void> _onBuildRoute(
    BuildRoute event,
    Emitter<MapState> emit,
  ) async {
    if (state.currentLocation == null) {
      emit(state.copyWith(error: 'Нет текущей позиции'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final route = await getRoute(
        start: state.currentLocation!,
        end: event.destination, 
      );

      emit(state.copyWith(
        currentRoute: route,
        isLoading: false,
        forceCenter: true,
        isRouteCompleted: false,
      ));

      if (state.currentLocation != null) {
        final projection = RouteProjection.projectOnRoute(
          state.currentLocation!,
          route.points,
        );

        emit(state.copyWith(                  
          currentSegmentIndex: projection.segmentIndex,
          projectedLocation: projection.projectedPoint,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
  
  void _onClearRoute(ClearRoute event, Emitter<MapState> emit) {
    emit(state.copyWith(
      currentRoute: null,
      currentSegmentIndex: 0,
      projectedLocation: null,
    ));
  }

  void _onResetForceCenter(
    ResetForceCenter event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(forceCenter: false));
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<MapState> emit,
  ) {
    final updatedState = state.copyWith(
      currentLocation: event.location,
    );
    emit(updatedState);

    _updateRouteProgressIfNeeded(event.location, updatedState, emit);
  }

  void _onUpdateRouteProgress(
    UpdateRouteProgress event,
    Emitter<MapState> emit,
  ) {
    final updatedState = state.copyWith(
      currentLocation: event.currentLocation,
    );
    emit(updatedState);

    _updateRouteProgressIfNeeded(event.currentLocation, updatedState, emit);
  }

  void _updateRouteProgressIfNeeded(
    Location location,
    MapState currentState,
    Emitter<MapState> emit,
  ) {
    if (currentState.isRouteCompleted) return;

    final currentRoute = currentState.currentRoute;
    if (currentRoute == null) return;

    final destination = currentRoute.points.last;
    final distanceToFinish = calc.DistanceCalculator.betweenLocations(
      location,
      Location(
        latitude: destination.latitude,
        longitude: destination.longitude,
      ),
    );

    if (distanceToFinish < 20) {
      print('Маршрут завершен');
      emit(currentState.copyWith(
        currentRoute: null,
        currentSegmentIndex: 0,
        projectedLocation: null,
        isRouteCompleted: true,
      ));
      return;
    }

    final projection = RouteProjection.projectOnRoute(
      location,
      currentRoute.points,
    );

    emit(currentState.copyWith(
      currentSegmentIndex: projection.segmentIndex,
      projectedLocation: projection.projectedPoint,
    ));
  }
}