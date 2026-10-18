import '../entities/trip.dart';

abstract class TripsRepository {
  Future<List<Trip>> getTrips();
  Future<List<Trip>> searchTrips({
    required String originCode,
    required String destinationCode,
    DateTime? date,
  });
  Future<Trip> getTripDetails(int id);
}
