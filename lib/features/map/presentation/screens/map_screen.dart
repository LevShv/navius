import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../../core/di/injection.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navius')),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.currentLocation != null) {
            _mapController.move(
              LatLng(
                state.currentLocation!.latitude,
                state.currentLocation!.longitude,
              ),
              14.0,
            );
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
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.navius',
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
          return FloatingActionButton(
            onPressed: state.currentLocation != null
                ? () => _mapController.move(
                    LatLng(
                      state.currentLocation!.latitude,
                      state.currentLocation!.longitude,
                    ),
                    14.0,
                  )
                : null,
            child: const Icon(Icons.my_location),
          );
        },
      ),
    );
  }
}