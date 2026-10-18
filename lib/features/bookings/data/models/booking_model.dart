import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.pnrCode,
    required super.tripId,
    super.passengerId,
    required super.seatId,
    super.bookedBy,
    required super.totalPrice,
    required super.status,
    super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    int? asNullableInt(dynamic v) =>
        v is num ? v.toInt() : (v == null ? null : int.tryParse('$v'));
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    DateTime? asDate(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return BookingModel(
      id: asInt(json['id']),
      pnrCode: '${json['pnr_code'] ?? ''}',
      tripId: asInt(json['trip_id']),
      passengerId: asNullableInt(json['passenger_id']),
      seatId: asInt(json['seat_id']),
      bookedBy: asNullableInt(json['booked_by']),
      totalPrice: asDouble(json['total_price']),
      status: '${json['status'] ?? 'unknown'}',
      createdAt: asDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pnr_code': pnrCode,
    'trip_id': tripId,
    'passenger_id': passengerId,
    'seat_id': seatId,
    'booked_by': bookedBy,
    'total_price': totalPrice,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
  };
}
