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

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      currentLocation: event.location,
    ));

    if (state.currentRoute != null){
      add(UpdateRouteProgress(event.location));      
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
      ));
    }
    catch (e) {
        emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearRoute(
    ClearRoute event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      currentRoute: null));
  }

  void _onResetForceCenter(
    ResetForceCenter event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(forceCenter: false));
  }

  void _onUpdateRouteProgress(
    UpdateRouteProgress event,
    Emitter<MapState> emit,
  ) {
    if (state.currentRoute == null) {
      return;
    }

    final projection =
        RouteProjection.projectOnRoute(
      event.currentLocation,
      state.currentRoute!.points,
    );

    emit(
      state.copyWith(
        currentSegmentIndex:
            projection.segmentIndex,

        projectedLocation:
            projection.projectedPoint,
      ),
    );
    final destination = state.currentRoute!.points.last;
    final distanceToFinish =
        calc.DistanceCalculator.between(
      event.currentLocation,
      Location(
        latitude: destination.latitude,
        longitude: destination.longitude,
      ),
    );

    print(
      'distanceToFinish = $distanceToFinish',
    );

    if (distanceToFinish < 20) {
      print('Маршрут завершён');

      add(ClearRoute());
    }
  }
}