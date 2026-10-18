class Booking {
  final int id;
  final String pnrCode;
  final int tripId;
  final int? passengerId;
  final int seatId;
  final int? bookedBy;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.pnrCode,
    required this.tripId,
    this.passengerId,
    required this.seatId,
    this.bookedBy,
    required this.totalPrice,
    required this.status,
    this.createdAt,
  });
}
