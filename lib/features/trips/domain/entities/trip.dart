class Trip {
  final int id, routeId, totalSeats, availableSeats;
  final String flightNumber, aircraftName, status, aircraftImageUrl;
  final DateTime? departureTime, arrivalTime, createdAt;
  final double basePrice;
  final List<dynamic> seats;

  const Trip({
    required this.id, required this.routeId, required this.flightNumber,
    required this.aircraftName, required this.departureTime,
    required this.arrivalTime, required this.totalSeats,
    required this.availableSeats, required this.basePrice, required this.status,
    required this.aircraftImageUrl, required this.createdAt, required this.seats,
  });
}
