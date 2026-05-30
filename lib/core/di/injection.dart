import 'package:get_it/get_it.dart';
import 'package:navius/features/map/domain/repositories/location_repository.dart';

import '../../features/map/data/datasources/location_datasource.dart';
import '../../features/map/data/repositories/location_repository_impl.dart';
import '../../features/map/domain/usecases/get_current_location.dart';
import '../../features/map/domain/usecases/get_location_stream.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';

import '../../features/map/data/datasources/route_datasource.dart';
import '../../features/map/data/repositories/route_repository_impl.dart';
import '../../features/map/domain/repositories/route_repository.dart';
import '../../features/map/domain/usecases/get_route.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  // Внешине
  sl.registerLazySingleton(() => http.Client());

  // MapBloc
  sl.registerFactory(
    () => MapBloc(
      getCurrentLocation: sl(),
      getLocationStream: sl(),
      getRoute: sl(),
    )
  );

  // Map Usecases
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetLocationStream(sl()));
  sl.registerLazySingleton(() => GetRoute(sl()));

  // Map Repository
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(sl()));
  sl.registerLazySingleton<RouteRepository>(() => RouteRepositoryImpl(sl()));

  // Map Datasources
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());
  sl.registerLazySingleton(() => RouteDataSource(client: sl()));
}

