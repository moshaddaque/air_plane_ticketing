import '../entities/flight_route.dart';

abstract class RoutesRepository {
  Future<List<FlightRoute>> getRoutes();
}
