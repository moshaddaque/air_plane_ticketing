import 'package:air_plane_ticketing/core/network/api_client.dart';
import '../models/flight_route_model.dart';

class RoutesRemoteDataSource {
  final ApiClient _apiClient;

  RoutesRemoteDataSource(this._apiClient);

  Future<List<FlightRouteModel>> getRoutes() async {
    final rows = await _apiClient.getList('/api/v1/routes/');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(FlightRouteModel.fromJson)
        .where((route) => route.isActive)
        .toList();
  }
}
