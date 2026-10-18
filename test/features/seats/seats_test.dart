import 'package:air_plane_ticketing/features/seats/data/models/seat_model.dart';
import 'package:air_plane_ticketing/features/seats/domain/entities/seat.dart';
import 'package:air_plane_ticketing/features/seats/domain/repositories/seats_repository.dart';
import 'package:air_plane_ticketing/features/seats/presentation/providers/seats_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSeatsRepository implements SeatsRepository {
  final List<Seat> fakeSeats;

  FakeSeatsRepository(this.fakeSeats);

  @override
  Future<List<Seat>> getSeatsByTrip(int tripId) async => fakeSeats;

  @override
  Future<List<Seat>> getAvailableSeatsByTrip(int tripId, {String? seatClass}) async {
    return fakeSeats.where((s) => s.isAvailable).toList();
  }
}

void main() {
  group('SeatModel', () {
    test('parses JSON correctly', () {
      final json = {
        'id': 985,
        'trip_id': 13,
        'seat_number': 'E001',
        'seat_class': 'economy',
        'price': 5000.0,
        'is_available': true,
        'created_at': '2026-08-17T07:52:02.319424Z',
      };

      final seat = SeatModel.fromJson(json);

      expect(seat.id, 985);
      expect(seat.tripId, 13);
      expect(seat.seatNumber, 'E001');
      expect(seat.seatClass, 'economy');
      expect(seat.price, 5000.0);
      expect(seat.isAvailable, true);
      expect(seat.createdAt, isNotNull);
    });
  });

  group('SeatsProvider', () {
    late SeatsProvider provider;
    final testSeats = [
      const Seat(
        id: 1,
        tripId: 10,
        seatNumber: 'E001',
        seatClass: 'economy',
        price: 5000,
        isAvailable: true,
      ),
      const Seat(
        id: 2,
        tripId: 10,
        seatNumber: 'E002',
        seatClass: 'economy',
        price: 5000,
        isAvailable: false,
      ),
      const Seat(
        id: 3,
        tripId: 10,
        seatNumber: 'B001',
        seatClass: 'business',
        price: 12000,
        isAvailable: true,
      ),
    ];

    setUp(() {
      provider = SeatsProvider(FakeSeatsRepository(testSeats));
    });

    test('loads seats and calculates totals correctly', () async {
      await provider.loadSeats(10);

      expect(provider.seats.length, 3);
      expect(provider.totalSeatsCount, 3);
      expect(provider.availableSeatsCount, 2);
      expect(provider.bookedSeatsCount, 1);
    });

    test('selects and deselects available seats', () async {
      await provider.loadSeats(10);

      final result1 = provider.toggleSeatSelection(testSeats[0]);
      expect(result1, SeatSelectionResult.selected);
      expect(provider.selectedSeat?.id, 1);

      final result2 = provider.toggleSeatSelection(testSeats[0]);
      expect(result2, SeatSelectionResult.deselected);
      expect(provider.selectedSeat, isNull);
    });

    test('rejects unavailable seats', () async {
      await provider.loadSeats(10);

      final result = provider.toggleSeatSelection(testSeats[1]);
      expect(result, SeatSelectionResult.notAvailable);
      expect(provider.selectedSeat, isNull);
    });

    test('filters seats by class', () async {
      await provider.loadSeats(10);

      provider.setClassFilter('business');
      expect(provider.filteredSeats.length, 1);
      expect(provider.filteredSeats.first.seatNumber, 'B001');

      provider.setClassFilter('all');
      expect(provider.filteredSeats.length, 3);
    });
  });
}
