import '../../domain/entities/flight_route.dart';
import '../../domain/repositories/routes_repository.dart';
import '../datasources/routes_remote_data_source.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final RoutesRemoteDataSource _dataSource;

  RoutesRepositoryImpl(this._dataSource);

  @override
  Future<List<FlightRoute>> getRoutes() => _dataSource.getRoutes();
}
