import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/booking_model.dart';
import '../models/booking_request_model.dart';

class BookingRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  BookingRemoteDataSource(this._apiClient, this._secureStorage);

  Future<BookingModel> createBooking(BookingRequestModel request) async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(
        message: 'Your session has expired. Please sign in again.',
      );
    }

    final response = await _apiClient.post(
      ApiConstants.bookings,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: request.toJson(),
    );

    return BookingModel.fromJson(response);
  }

  Future<List<BookingModel>> getMyBookings() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(
        message: 'Your session has expired. Please sign in again.',
      );
    }

    final rows = await _apiClient.getList(
      ApiConstants.myBookings,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return rows
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }
}
