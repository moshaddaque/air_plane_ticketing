import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/seat_model.dart';

class SeatsRemoteDataSource {
  final ApiClient _apiClient;

  SeatsRemoteDataSource(this._apiClient);

  Future<List<SeatModel>> getSeatsByTrip(int tripId) async {
    final rows = await _apiClient.getList(ApiConstants.tripSeats(tripId));
    return rows
        .whereType<Map<String, dynamic>>()
        .map(SeatModel.fromJson)
        .toList();
  }

  Future<List<SeatModel>> getAvailableSeatsByTrip(
    int tripId, {
    String? seatClass,
  }) async {
    final query = <String, String>{};
    if (seatClass != null && seatClass.trim().isNotEmpty) {
      query['seat_class'] = seatClass.trim();
    }

    final rows = await _apiClient.getList(
      ApiConstants.availableTripSeats(tripId),
      queryParameters: query.isNotEmpty ? query : null,
    );
    return rows
        .whereType<Map<String, dynamic>>()
        .map(SeatModel.fromJson)
        .toList();
  }
}
