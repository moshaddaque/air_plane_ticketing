import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../trips/domain/entities/trip.dart';
import '../../domain/entities/seat.dart';
import '../providers/seats_provider.dart';
import '../widgets/seat_widget.dart';
import '../widgets/seats_header.dart';

class SeatsScreen extends StatefulWidget {
  final Trip trip;

  const SeatsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SeatsProvider>().loadSeats(widget.trip.id);
      }
    });
  }

  void _onSeatTap(Seat seat) {
    final provider = context.read<SeatsProvider>();
    final result = provider.toggleSeatSelection(seat);

    if (result == SeatSelectionResult.notAvailable) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seat ${seat.seatNumber} is already booked and not available.',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onBookingPressed() {
    final provider = context.read<SeatsProvider>();
    final selectedSeat = provider.selectedSeat;

    if (selectedSeat == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select an available seat before booking.',
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _showBookingConfirmationDialog(selectedSeat);
  }

  void _showBookingConfirmationDialog(Seat seat) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Seat Booking',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Flight: ${widget.trip.flightNumber.isEmpty ? '#${widget.trip.id}' : widget.trip.flightNumber} · ${widget.trip.aircraftName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Selected Seat',
                        value: seat.seatNumber,
                        isBold: true,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Class',
                        value: seat.seatClass.toUpperCase(),
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Price',
                        value: '৳${seat.price.toStringAsFixed(2)}',
                        valueColor: theme.colorScheme.primary,
                        isBold: true,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Status',
                        value: 'Available for Booking',
                        valueColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Seat ${seat.seatNumber} selected successfully! Ready for booking.',
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Booking'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SeatsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Seats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${widget.trip.flightNumber.isEmpty ? "Flight #${widget.trip.id}" : widget.trip.flightNumber} · ${widget.trip.aircraftName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadSeats(widget.trip.id, force: true),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading seat map...'),
                ],
              ),
            )
          : provider.errorMessage != null && provider.seats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 56,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              provider.loadSeats(widget.trip.id, force: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : provider.seats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.airline_seat_recline_normal,
                              size: 56,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No seats configured for this flight yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => provider.loadSeats(
                                widget.trip.id,
                                force: true,
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Header with total seats and available seats
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: SeatsHeader(
                            totalSeats: provider.totalSeatsCount,
                            availableSeats: provider.availableSeatsCount,
                            bookedSeats: provider.bookedSeatsCount,
                          ),
                        ),

                        // Class Filter Chips if multiple classes exist
                        if (provider.availableClasses.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: Text(
                                    'All (${provider.totalSeatsCount})',
                                  ),
                                  selected: provider.classFilter == 'all',
                                  onSelected: (_) =>
                                      provider.setClassFilter('all'),
                                ),
                                const SizedBox(width: 8),
                                ...provider.availableClasses.map((cls) {
                                  final count = provider.seats
                                      .where((s) =>
                                          s.seatClass.toLowerCase() ==
                                          cls.toLowerCase())
                                      .length;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        '${cls[0].toUpperCase()}${cls.substring(1)} ($count)',
                                      ),
                                      selected: provider.classFilter == cls,
                                      onSelected: (_) =>
                                          provider.setClassFilter(cls),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),

                        // Cabin front indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AIRCRAFT FRONT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Seat Grid
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () =>
                                provider.loadSeats(widget.trip.id, force: true),
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.88,
                              ),
                              itemCount: provider.filteredSeats.length,
                              itemBuilder: (context, index) {
                                final seat = provider.filteredSeats[index];
                                final isSelected =
                                    provider.selectedSeat?.id == seat.id;

                                return SeatWidget(
                                  seat: seat,
                                  isSelected: isSelected,
                                  onTap: () => _onSeatTap(seat),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: provider.seats.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.selectedSeat != null
                                ? 'Seat ${provider.selectedSeat!.seatNumber} (${provider.selectedSeat!.seatClass})'
                                : 'No seat selected',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.selectedSeat != null
                                ? '৳${provider.selectedSeat!.price.toStringAsFixed(0)}'
                                : 'Select an available seat',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: provider.selectedSeat != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: provider.selectedSeat != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _onBookingPressed,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Book Seat'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
