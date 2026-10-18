import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id, required super.routeId, required super.flightNumber,
    required super.aircraftName, required super.departureTime,
    required super.arrivalTime, required super.totalSeats,
    required super.availableSeats, required super.basePrice,
    required super.status, required super.aircraftImageUrl,
    required super.createdAt, required super.seats,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    DateTime? asDate(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return TripModel(
      id: asInt(json['id']),
      routeId: asInt(json['route_id']),
      flightNumber: '${json['flight_number'] ?? ''}',
      aircraftName: '${json['aircraft_name'] ?? 'Aircraft'}',
      departureTime: asDate(json['departure_time']),
      arrivalTime: asDate(json['arrival_time']),
      totalSeats: asInt(json['total_seats']),
      availableSeats: asInt(json['available_seats']),
      basePrice: asDouble(json['base_price']),
      status: '${json['status'] ?? 'unknown'}',
      aircraftImageUrl: '${json['aircraft_image_url'] ?? ''}',
      createdAt: asDate(json['created_at']),
      seats: json['seats'] is List ? List<dynamic>.from(json['seats']) : const [],
    );
  }
}
