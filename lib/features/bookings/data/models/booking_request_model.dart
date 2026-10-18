class BookingRequestModel {
  final int tripId;
  final int seatId;
  final int? passengerId;

  const BookingRequestModel({
    required this.tripId,
    required this.seatId,
    this.passengerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'seat_id': seatId,
      if (passengerId != null && passengerId! > 0)
        'passenger_id': passengerId
      else
        'passenger_id': null,
    };
  }
}
