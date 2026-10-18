import 'package:air_plane_ticketing/features/bookings/data/models/booking_model.dart';
import 'package:air_plane_ticketing/features/bookings/data/models/booking_request_model.dart';
import 'package:air_plane_ticketing/features/bookings/domain/entities/booking.dart';
import 'package:air_plane_ticketing/features/bookings/domain/repositories/booking_repository.dart';
import 'package:air_plane_ticketing/features/bookings/presentation/providers/booking_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBookingRepository implements BookingRepository {
  final List<Booking> fakeBookings;
  bool shouldFail = false;

  FakeBookingRepository(this.fakeBookings);

  @override
  Future<Booking> createBooking({
    required int tripId,
    required int seatId,
    int? passengerId,
  }) async {
    if (shouldFail) {
      throw Exception('Server error creating booking');
    }
    return Booking(
      id: 99,
      pnrCode: 'PNR-NEW-123',
      tripId: tripId,
      seatId: seatId,
      passengerId: passengerId,
      bookedBy: 1,
      totalPrice: 5000,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    if (shouldFail) {
      throw Exception('Server error fetching bookings');
    }
    return fakeBookings;
  }
}

void main() {
  group('BookingModel', () {
    test('parses JSON correctly', () {
      final json = {
        'id': 12,
        'pnr_code': 'BG-PNR-789',
        'trip_id': 7,
        'passenger_id': 3,
        'seat_id': 985,
        'booked_by': 1,
        'total_price': 8500.0,
        'status': 'confirmed',
        'created_at': '2026-10-18T16:17:51.792Z',
      };

      final model = BookingModel.fromJson(json);

      expect(model.id, 12);
      expect(model.pnrCode, 'BG-PNR-789');
      expect(model.tripId, 7);
      expect(model.passengerId, 3);
      expect(model.seatId, 985);
      expect(model.bookedBy, 1);
      expect(model.totalPrice, 8500.0);
      expect(model.status, 'confirmed');
      expect(model.createdAt, isNotNull);
    });

    test('toJson serializes correctly', () {
      final request = const BookingRequestModel(
        tripId: 7,
        seatId: 985,
        passengerId: 3,
      );

      final json = request.toJson();
      expect(json['trip_id'], 7);
      expect(json['seat_id'], 985);
      expect(json['passenger_id'], 3);
    });
  });

  group('BookingProvider', () {
    late BookingProvider provider;
    late FakeBookingRepository repository;

    final initialBookings = [
      Booking(
        id: 1,
        pnrCode: 'PNR-001',
        tripId: 7,
        seatId: 985,
        passengerId: 3,
        bookedBy: 1,
        totalPrice: 5000,
        status: 'confirmed',
        createdAt: DateTime.now(),
      ),
    ];

    setUp(() {
      repository = FakeBookingRepository(initialBookings);
      provider = BookingProvider(repository);
    });

    test('loads my bookings', () async {
      await provider.loadMyBookings();

      expect(provider.bookings.length, 1);
      expect(provider.bookings.first.pnrCode, 'PNR-001');
      expect(provider.errorMessage, isNull);
    });

    test('creates booking and prepends to list', () async {
      final booking = await provider.createBooking(
        tripId: 10,
        seatId: 120,
        passengerId: 5,
      );

      expect(booking, isNotNull);
      expect(booking?.pnrCode, 'PNR-NEW-123');
      expect(provider.bookings.length, 1);
      expect(provider.bookings.first.pnrCode, 'PNR-NEW-123');
    });

    test('handles creation failure properly', () async {
      repository.shouldFail = true;

      final booking = await provider.createBooking(
        tripId: 10,
        seatId: 120,
      );

      expect(booking, isNull);
      expect(provider.bookingError, isNotNull);
    });
  });
}
