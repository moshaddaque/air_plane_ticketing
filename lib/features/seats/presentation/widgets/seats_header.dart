import 'package:flutter/material.dart';

class SeatsHeader extends StatelessWidget {
  final int totalSeats;
  final int availableSeats;
  final int bookedSeats;

  const SeatsHeader({
    super.key,
    required this.totalSeats,
    required this.availableSeats,
    required this.bookedSeats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Seats',
                  value: '$totalSeats',
                  icon: Icons.airline_seat_recline_normal,
                  color: theme.colorScheme.primary,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: theme.colorScheme.outlineVariant.withAlpha(120),
              ),
              Expanded(
                child: _StatCard(
                  label: 'Available',
                  value: '$availableSeats',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: theme.colorScheme.outlineVariant.withAlpha(120),
              ),
              Expanded(
                child: _StatCard(
                  label: 'Booked',
                  value: '$bookedSeats',
                  icon: Icons.block_outlined,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(
                color: theme.colorScheme.surfaceContainerLow,
                borderColor: theme.colorScheme.primary.withAlpha(150),
                label: 'Available',
              ),
              _LegendItem(
                color: theme.colorScheme.primary,
                borderColor: theme.colorScheme.primary,
                label: 'Selected',
              ),
              _LegendItem(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(140),
                borderColor: theme.colorScheme.outlineVariant.withAlpha(100),
                label: 'Unavailable',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
