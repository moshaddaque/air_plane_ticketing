import 'package:air_plane_ticketing/core/network/api_client.dart';
import '../models/trip_model.dart';

class TripsRemoteDataSource {
  final ApiClient _api;
  TripsRemoteDataSource(this._api);

  Future<List<TripModel>> getTrips() async {
    final rows = await _api.getList('/api/v1/trips/');
    return rows.whereType<Map<String, dynamic>>().map(TripModel.fromJson).toList();
  }

  Future<List<TripModel>> searchTrips({
    required String originCode,
    required String destinationCode,
    DateTime? date,
  }) async {
    final query = <String, String>{
      'origin_code': originCode.trim().toUpperCase(),
      'destination_code': destinationCode.trim().toUpperCase(),
    };
    if (date != null) {
      query['date'] = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
    final rows = await _api.getList(
      '/api/v1/trips/search',
      queryParameters: query,
    );
    return rows.whereType<Map<String, dynamic>>().map(TripModel.fromJson).toList();
  }

  Future<TripModel> getTripDetails(int id) async =>
      TripModel.fromJson(await _api.get('/api/v1/trips/$id'));
}
