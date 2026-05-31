import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<Position> getCurrentLocation();
  Stream<Position> getPositionStream();

}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        throw Exception('Location service is disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      Position? position = await Geolocator.getCurrentPosition();

      print('Получена новая позиция: ${position.latitude}, ${position.longitude}');
      return position;

    } catch (e, stack) {
      print('Ошибка getCurrentLocation: $e');
      print(stack);
      rethrow;
    }
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
       // distanceFilter: 1, 
       // timeLimit: Duration(milliseconds: 500), 
      ),
    ); 
  }
}