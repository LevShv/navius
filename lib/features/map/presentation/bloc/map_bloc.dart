import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';
import '../../domain/usecases/get_current_location.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;

  MapBloc({required this.getCurrentLocation}) : super(const MapState()) {
      on<LoadLocation>(_onLoadLocation);
      on<CenterOnUser>(_onCenterOnUser);
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
    //emit(state.copyWith(isLoading: true));
    try {
      final location = await getCurrentLocation();

      emit(MapState(
        currentLocation: location,
        isLoading: false,
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
}