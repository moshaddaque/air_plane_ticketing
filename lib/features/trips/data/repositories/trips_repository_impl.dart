import '../../domain/entities/trip.dart';
import '../../domain/repositories/trips_repository.dart';
import '../datasources/trips_remote_data_source.dart';

class TripsRepositoryImpl implements TripsRepository {
  final TripsRemoteDataSource _source;
  TripsRepositoryImpl(this._source);

  @override
  Future<List<Trip>> getTrips() => _source.getTrips();

  @override
  Future<List<Trip>> searchTrips({
    required String originCode,
    required String destinationCode,
    DateTime? date,
  }) => _source.searchTrips(
    originCode: originCode, destinationCode: destinationCode, date: date,
  );

  @override
  Future<Trip> getTripDetails(int id) => _source.getTripDetails(id);
}
