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

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MapBloc>()..add(LoadLocation()),
      child: const MapView(),
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
            },
            builder: (context, state) {
              return _buildMap(state);
            },
          ),
          
          BlocBuilder<MapBloc, MapState>(
            buildWhen: (previous, current) {
              return previous.routeProgress != current.routeProgress &&
                     current.routeProgress != null;
            },
            builder: (context, state) {
              if (state.routeProgress != null && 
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
          context.read<MapBloc>().add(StartRouting(
            Location(
              latitude: point.latitude,
              longitude: point.longitude,
            ),
          ));
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Маршрут строится...'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.navius',
        ),
        if (state.currentRoute != null && !state.isRouteCompleted)
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
  
  // Исправленный метод для FAB с отслеживанием состояния маршрута
  Widget _buildFloatingActionButton() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        // Проверяем, есть ли активный маршрут
        final hasActiveRoute = state.routeProgress != null && 
                               state.currentRoute != null && 
                               !state.isRouteCompleted;
        
        // Если маршрут активен - поднимаем кнопку над карточкой
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