import 'package:flutter/material.dart';
import '../../domain/entities/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  const TripCard({super.key, required this.trip, required this.onTap});

  String _time(DateTime? value) {
    if (value == null) return '--:--';
    final d = value.toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _date(DateTime? value) {
    if (value == null) return 'Date unavailable';
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _duration() {
    if (trip.departureTime == null || trip.arrivalTime == null) return '--';
    final d = trip.arrivalTime!.difference(trip.departureTime!);
    if (d.isNegative) return '--';
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = trip.aircraftImageUrl.trim();
    Widget fallback() => ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Icon(Icons.flight, size: 34, color: theme.colorScheme.primary),
    );

    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerLow, clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 72, height: 66,
                  child: image.isEmpty ? fallback() : Image.network(
                    image, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trip.flightNumber.isEmpty ? 'Flight #${trip.id}' : trip.flightNumber,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(trip.aircraftName, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(trip.status.replaceAll('_', ' '),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
              ])),
              const SizedBox(width: 6),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('৳${trip.basePrice.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                Text('per seat', style: theme.textTheme.bodySmall),
              ]),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _TimeBlock(label: 'DEPARTURE', time: _time(trip.departureTime),
                date: _date(trip.departureTime), align: CrossAxisAlignment.start)),
              Column(children: [
                Icon(Icons.flight_takeoff, color: theme.colorScheme.primary),
                Text(_duration(), style: theme.textTheme.labelSmall),
              ]),
              Expanded(child: _TimeBlock(label: 'ARRIVAL', time: _time(trip.arrivalTime),
                date: _date(trip.arrivalTime), align: CrossAxisAlignment.end)),
            ]),
            const SizedBox(height: 12), const Divider(height: 1), const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.event_seat_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text('${trip.availableSeats} of ${trip.totalSeats} seats available',
                style: theme.textTheme.bodySmall)),
              Text('Details  ›', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label, time, date;
  final CrossAxisAlignment align;
  const _TimeBlock({required this.label, required this.time, required this.date, required this.align});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: align, children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 4),
      Text(time, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      Text(date, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
