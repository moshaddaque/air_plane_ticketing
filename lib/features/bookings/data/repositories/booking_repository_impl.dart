import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_request_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Booking> createBooking({
    required int tripId,
    required int seatId,
    int? passengerId,
  }) {
    final request = BookingRequestModel(
      tripId: tripId,
      seatId: seatId,
      passengerId: passengerId,
    );
    return _remoteDataSource.createBooking(request);
  }

  @override
  Future<List<Booking>> getMyBookings() {
    return _remoteDataSource.getMyBookings();
  }
}
