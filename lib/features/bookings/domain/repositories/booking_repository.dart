import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Booking> createBooking({
    required int tripId,
    required int seatId,
    int? passengerId,
  });

  Future<List<Booking>> getMyBookings();
}
