import 'package:get_it/get_it.dart';
import 'package:navius/features/map/domain/repositories/location_repository.dart';

import '../../features/map/data/datasources/location_datasource.dart';
import '../../features/map/data/repositories/location_repository_impl.dart';
import '../../features/map/domain/usecases/get_current_location.dart';
import '../../features/map/domain/usecases/get_location_stream.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(
    () => MapBloc(
      getCurrentLocation: sl(),
      getLocationStream: sl(),
    )
  );

  sl.registerLazySingleton(
    () => GetCurrentLocation(sl())
  );

   sl.registerLazySingleton(
    () => GetLocationStream(sl())
  );

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl())
  );

  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(),
  );
}

