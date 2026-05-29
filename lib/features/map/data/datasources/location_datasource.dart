import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<Position> getCurrentLocation();
  Stream<Position> getPositionStream();

}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream();
  }
}