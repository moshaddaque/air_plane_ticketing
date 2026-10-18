import '../entities/seat.dart';

abstract class SeatsRepository {
  Future<List<Seat>> getSeatsByTrip(int tripId);
  Future<List<Seat>> getAvailableSeatsByTrip(int tripId, {String? seatClass});
}
