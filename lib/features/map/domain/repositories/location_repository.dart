import '../entities/location.dart';

abstract class LocationRepository {
  Future<Location> getCurrentLocation();
  Stream<Location> getLocationStream();
}