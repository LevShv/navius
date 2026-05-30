import '../repositories/location_repository.dart';
import '../entities/location.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  Future<Location> call() async {
    return await repository.getCurrentLocation();
  }
}