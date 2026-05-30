import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  
  @override
  Future<Location> getCurrentLocation() async {
    final position = await dataSource.getCurrentLocation();
    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Stream<Location> getLocationStream() {
    return dataSource.getPositionStream().map((position) => Location(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }
}