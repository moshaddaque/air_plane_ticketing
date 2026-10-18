class FlightRoute {
  final int id;
  final String origin;
  final String destination;
  final String originCode;
  final String destinationCode;
  final double distanceKm;
  final int durationMinutes;
  final bool isActive;
  final String imageUrl;
  final DateTime? createdAt;

  const FlightRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.originCode,
    required this.destinationCode,
    required this.distanceKm,
    required this.durationMinutes,
    required this.isActive,
    required this.imageUrl,
    required this.createdAt,
  });
}
