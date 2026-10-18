import '../../domain/entities/seat.dart';

class SeatModel extends Seat {
  const SeatModel({
    required super.id,
    required super.tripId,
    required super.seatNumber,
    required super.seatClass,
    required super.price,
    required super.isAvailable,
    super.createdAt,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    DateTime? asDate(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return SeatModel(
      id: asInt(json['id']),
      tripId: asInt(json['trip_id']),
      seatNumber: '${json['seat_number'] ?? ''}',
      seatClass: '${json['seat_class'] ?? 'economy'}',
      price: asDouble(json['price']),
      isAvailable: json['is_available'] == true,
      createdAt: asDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip_id': tripId,
    'seat_number': seatNumber,
    'seat_class': seatClass,
    'price': price,
    'is_available': isAvailable,
    'created_at': createdAt?.toIso8601String(),
  };
}
