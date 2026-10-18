import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/trip.dart';
import '../providers/trips_provider.dart';

class TripDetailsScreen extends StatefulWidget {
  final int tripId;
  const TripDetailsScreen({super.key, required this.tripId});
  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Future<Trip?> _future;
  @override
  void initState() {
    super.initState();
    _future = context.read<TripsProvider>().fetchTripDetails(widget.tripId);
  }

  String _dateTime(DateTime? value) {
    if (value == null) return 'Not available';
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Trip details')),
      body: FutureBuilder<Trip?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final trip = snapshot.data;
          if (trip == null) {
            final error = context.watch<TripsProvider>().errorMessage ?? 'Unable to load trip details.';
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12),
                Text(error, textAlign: TextAlign.center), const SizedBox(height: 16),
                FilledButton.icon(onPressed: () => setState(() {
                  _future = context.read<TripsProvider>().fetchTripDetails(widget.tripId);
                }), icon: const Icon(Icons.refresh), label: const Text('Retry')),
              ]),
            ));
          }
          final image = trip.aircraftImageUrl.trim();
          Widget fallback() => ColoredBox(
            color: theme.colorScheme.primaryContainer,
            child: Center(child: Icon(Icons.flight, size: 70, color: theme.colorScheme.primary)),
          );
          return ListView(padding: const EdgeInsets.all(16), children: [
            ClipRRect(borderRadius: BorderRadius.circular(16),
              child: SizedBox(height: 190, child: image.isEmpty ? fallback() : Image.network(
                image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback()))),
            const SizedBox(height: 18),
            Text(trip.flightNumber.isEmpty ? 'Flight #${trip.id}' : trip.flightNumber,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4), Text(trip.aircraftName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Card(elevation: 0, color: theme.colorScheme.surfaceContainerLow,
              child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                Expanded(child: _Info(label: 'Departure', value: _dateTime(trip.departureTime), icon: Icons.flight_takeoff)),
                const SizedBox(width: 12),
                Expanded(child: _Info(label: 'Arrival', value: _dateTime(trip.arrivalTime), icon: Icons.flight_land)),
              ]))),
            const SizedBox(height: 12),
            Card(elevation: 0, color: theme.colorScheme.surfaceContainerLow, child: Column(children: [
              _Tile(icon: Icons.confirmation_number_outlined, label: 'Trip ID', value: '${trip.id}'),
              const Divider(height: 1),
              _Tile(icon: Icons.alt_route_outlined, label: 'Route ID', value: '${trip.routeId}'),
              const Divider(height: 1),
              _Tile(icon: Icons.event_seat_outlined, label: 'Available seats', value: '${trip.availableSeats} / ${trip.totalSeats}'),
              const Divider(height: 1),
              _Tile(icon: Icons.info_outline, label: 'Status', value: trip.status.replaceAll('_', ' ')),
              const Divider(height: 1),
              _Tile(icon: Icons.payments_outlined, label: 'Base price', value: '৳${trip.basePrice.toStringAsFixed(2)}'),
            ])),
            const SizedBox(height: 16),
            const Text('Booking and seat selection can be connected when those API details are available.',
              textAlign: TextAlign.center),
          ]);
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Info({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 8),
    Text(label, style: Theme.of(context).textTheme.labelMedium), const SizedBox(height: 4),
    Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
  ]);
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Tile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(label, style: Theme.of(context).textTheme.bodySmall),
    subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
  );
}
