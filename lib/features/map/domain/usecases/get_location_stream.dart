import '../repositories/location_repository.dart';
import '../entities/location.dart';

class GetLocationStream {
  final LocationRepository repository;

  GetLocationStream(this.repository);

  Stream<Location> call() {
    return repository.getLocationStream();
  }
}