import '../../domain/entities/flight_route.dart';

class FlightRouteModel extends FlightRoute {
  const FlightRouteModel({
    required super.id,
    required super.origin,
    required super.destination,
    required super.originCode,
    required super.destinationCode,
    required super.distanceKm,
    required super.durationMinutes,
    required super.isActive,
    required super.imageUrl,
    required super.createdAt,
  });

  factory FlightRouteModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    double asDouble(dynamic value) => value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    DateTime? asDate(dynamic value) =>
        value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;

    return FlightRouteModel(
      id: asInt(json['id']),
      origin: '${json['origin'] ?? ''}',
      destination: '${json['destination'] ?? ''}',
      originCode: '${json['origin_code'] ?? ''}',
      destinationCode: '${json['destination_code'] ?? ''}',
      distanceKm: asDouble(json['distance_km']),
      durationMinutes: asInt(json['duration_minutes']),
      isActive: json['is_active'] == true,
      imageUrl: '${json['image_url'] ?? ''}',
      createdAt: asDate(json['created_at']),
    );
  }
}
