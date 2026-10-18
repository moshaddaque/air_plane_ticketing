class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://airplane.ictbangladesh.bd';

  static const String login = '/api/v1/auth/login';
  static const String me = '/api/v1/auth/me';

  static String tripSeats(int tripId) => '/api/v1/seats/trip/$tripId';
  static String availableTripSeats(int tripId) =>
      '/api/v1/seats/trip/$tripId/available';

  static const String bookings = '/api/v1/bookings/';
  static const String myBookings = '/api/v1/bookings/my';
}