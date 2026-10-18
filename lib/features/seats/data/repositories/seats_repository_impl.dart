import '../../domain/entities/seat.dart';
import '../../domain/repositories/seats_repository.dart';
import '../datasources/seats_remote_data_source.dart';

class SeatsRepositoryImpl implements SeatsRepository {
  final SeatsRemoteDataSource _remoteDataSource;

  SeatsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Seat>> getSeatsByTrip(int tripId) {
    return _remoteDataSource.getSeatsByTrip(tripId);
  }

  @override
  Future<List<Seat>> getAvailableSeatsByTrip(int tripId, {String? seatClass}) {
    return _remoteDataSource.getAvailableSeatsByTrip(tripId, seatClass: seatClass);
  }
}
