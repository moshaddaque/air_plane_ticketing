import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../domain/entities/booking.dart';

class CongratulationsDialog extends StatelessWidget {
  final Booking booking;
  final String? seatNumber;
  final String? flightNumber;

  const CongratulationsDialog({
    super.key,
    required this.booking,
    this.seatNumber,
    this.flightNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required Booking booking,
    String? seatNumber,
    String? flightNumber,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CongratulationsDialog(
        booking: booking,
        seatNumber: seatNumber,
        flightNumber: flightNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory icon with circle container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 50,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              '🎉 Congratulations!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            Text(
              'Your seat has been successfully booked.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // PNR & Booking details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(120),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PNR CODE',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.pnrCode,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  if (flightNumber != null && flightNumber!.isNotEmpty) ...[
                    _DialogRow(label: 'Flight', value: flightNumber!),
                    const SizedBox(height: 8),
                  ],

                  if (seatNumber != null && seatNumber!.isNotEmpty) ...[
                    _DialogRow(label: 'Seat', value: seatNumber!),
                    const SizedBox(height: 8),
                  ],

                  _DialogRow(
                    label: 'Total Price',
                    value: '৳${booking.totalPrice.toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),

                  _DialogRow(
                    label: 'Status',
                    value: booking.status.toUpperCase(),
                    valueColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions: "My Trips" and "Home"
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(initialIndex: 1),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: const Text('My Trips'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DialogRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
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
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
