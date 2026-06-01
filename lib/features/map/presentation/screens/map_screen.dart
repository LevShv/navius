import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/location.dart';
import '../../presentation/widgets/route_progress_card.dart';
import '../widgets/notification_manager.dart';
import '../../domain/entities/route.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MapBloc>()..add(LoadLocation()),
      child: NotificationOverlay( 
        child: const MapView(),
      ),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  bool _isMoving = false;
  bool _wasRouteBuilding = false;
  RouteInfo? _lastNotifiedRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<MapBloc, MapState>(
            listener: (context, state) {
              if (state.currentLocation != null && state.forceCenter) {
                final lat = state.currentLocation!.latitude;
                final lng = state.currentLocation!.longitude;
                
                Future.delayed(const Duration(milliseconds: 100), () {
                  _mapController.move(LatLng(lat, lng), 14.0);
                });
              }
              print(state.currentRoute);
              if (state.currentRoute != null && _wasRouteBuilding) {
                NotificationManager.show(
                  'Маршрут построен',
                  color: Colors.green,
                  duration: const Duration(seconds: 2),
                );
                _wasRouteBuilding = false;
                _lastNotifiedRoute = state.currentRoute;
              }
              
              if (state.error != null && _wasRouteBuilding) {
                print('=== ОШИБКА ПОСТРОЕНИЯ: ${state.error} ==='); 
                _wasRouteBuilding = false;
                NotificationManager.show(
                  'Ошибка построения маршрута',
                  color: Colors.red,
                  duration: const Duration(seconds: 2),
                );
              }
              
              if (state.isLoading && state.currentRoute == null) {
                _wasRouteBuilding = true;
              }            
            },
            builder: (context, state) {
              return _buildMap(state);
            },
          ),
          
          BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state.showRouitingUi == true && 
                  state.routeProgress != null && 
                  state.currentRoute != null && 
                  !state.isRouteCompleted) {
                return Positioned(
                  bottom: 16, 
                  left: 16,
                  right: 16,
                  child: RouteProgressCard(progress: state.routeProgress!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  Widget _buildMap(MapState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final location = state.currentLocation;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: location != null
            ? LatLng(location.latitude, location.longitude)
            : const LatLng(55.751244, 37.618423),
        initialZoom: 14.0,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture && !_isMoving) {
            _isMoving = true;
            context.read<MapBloc>().add(UserMovedMap());
            
            Future.delayed(const Duration(milliseconds: 500), () {
              _isMoving = false;
            });
          }
        },
        onLongPress: (tapPosition, point) {
          _wasRouteBuilding = true;
          context.read<MapBloc>().add(StartRouting(
            Location(
              latitude: point.latitude,
              longitude: point.longitude,
            ),
          ));
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.navius',
        ),
        if (state.currentRoute != null && !state.isRouteCompleted && !state.isRouteLoading && state.showRouitingUi)
          _buildRouteLayer(state),
        if (location != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 60,
                height: 60,
                point: LatLng(location.latitude, location.longitude),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildRouteLayer(MapState state) {
    final bluePoints = <LatLng>[
      LatLng(
        state.projectedLocation!.latitude,
        state.projectedLocation!.longitude,
      ),
    ];
    
    bluePoints.addAll(
      state.currentRoute!.points
          .skip((state.currentSegmentIndex ?? 0) + 1)
          .map((p) => LatLng(p.latitude, p.longitude)),
    );
    
    return PolylineLayer(
      polylines: [
        Polyline(
          points: state.currentRoute!.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 6,
        ),
        if (bluePoints.length > 1)
          Polyline(
            points: bluePoints,
            color: Colors.blue,
            strokeWidth: 6,
          ),
      ],
    );
  }
  
  Widget _buildFloatingActionButton() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final hasActiveRoute = state.routeProgress != null && 
                               state.currentRoute != null && 
                               !state.isRouteCompleted;
        
        final bottomMargin = hasActiveRoute ? 180.0 : 16.0;
        
        return Padding(
          padding: EdgeInsets.only(bottom: bottomMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'center',
                onPressed: () {
                  context.read<MapBloc>().add(CenterOnUser());
                },
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        );
      },
    );
  }
}