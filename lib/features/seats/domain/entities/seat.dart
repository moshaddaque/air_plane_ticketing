class Seat {
  final int id;
  final int tripId;
  final String seatNumber;
  final String seatClass;
  final double price;
  final bool isAvailable;
  final DateTime? createdAt;

  const Seat({
    required this.id,
    required this.tripId,
    required this.seatNumber,
    required this.seatClass,
    required this.price,
    required this.isAvailable,
    this.createdAt,
  });
}
