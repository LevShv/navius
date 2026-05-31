import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/location.dart';

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
      appBar: AppBar(title: const Text('Navius')),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.currentLocation != null && state.forceCenter) {
            final lat = state.currentLocation!.latitude;
            final lng = state.currentLocation!.longitude;
            
            Future.delayed(const Duration(milliseconds: 100), () {
              _mapController.move(LatLng(lat, lng), 14.0);
            });

            context.read<MapBloc>().add(ResetForceCenter());
             
          }
        },
        builder: (context, state) {
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
              onLongPress: (tapPosition, point) {  
                context.read<MapBloc>().add(BuildRoute(
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
              if (state.currentRoute != null &&
                state.projectedLocation != null)
              Builder(
                builder: (_) {

                  final greenPoints = <LatLng>[];

                  greenPoints.addAll(state.currentRoute!.points
                    .take(
                      (state.currentSegmentIndex ?? 0) + 1,
                    )
                    .map(
                      (p) => LatLng(
                        p.latitude,
                        p.longitude,
                      ),
                    ),
                  );

                  greenPoints.add(
                    LatLng(
                      state.projectedLocation!.latitude,
                      state.projectedLocation!.longitude,
                    ),
                  );

                  final bluePoints = <LatLng>[
                    LatLng(
                      state.projectedLocation!.latitude,
                      state.projectedLocation!.longitude,
                    ),
                  ];

                  bluePoints.addAll(
                    state.currentRoute!.points
                        .skip(
                          (state.currentSegmentIndex ?? 0) + 1,
                        )
                        .map(
                          (p) => LatLng(
                            p.latitude,
                            p.longitude,
                          ),
                        ),
                  );

                  return PolylineLayer(
                    polylines: [

                      Polyline(
                        points: state.currentRoute!.points
                            .map(
                              (p) => LatLng(
                                p.latitude,
                                p.longitude,
                              ),
                            )
                            .toList(),
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 6,
                      ),

                      if (greenPoints.length > 1)
                        Polyline(
                          points: greenPoints,
                          color: Colors.green,
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
                },
              ),
              
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
        },
      ),
      floatingActionButton: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'center',
                onPressed: () {
                  context.read<MapBloc>().add(CenterOnUser());
                },
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 10),
              
            ],
          );
        },
      ),
    );
  }
}