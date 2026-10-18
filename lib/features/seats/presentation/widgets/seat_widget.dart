import 'package:flutter/material.dart';

import '../../domain/entities/seat.dart';

class SeatWidget extends StatelessWidget {
  final Seat seat;
  final bool isSelected;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = seat.isAvailable;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color iconColor;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
      iconColor = theme.colorScheme.onPrimary;
    } else if (!isAvailable) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest.withAlpha(140);
      borderColor = theme.colorScheme.outlineVariant.withAlpha(100);
      textColor = theme.colorScheme.outline;
      iconColor = theme.colorScheme.outline;
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
      borderColor = theme.colorScheme.primary.withAlpha(90);
      textColor = theme.colorScheme.onSurface;
      iconColor = theme.colorScheme.primary;
    }

    final isBusiness = seat.seatClass.toLowerCase() == 'business';

    return Tooltip(
      message: isAvailable
          ? '${seat.seatNumber} (${seat.seatClass}) - ৳${seat.price.toStringAsFixed(0)}'
          : '${seat.seatNumber} - Not Available',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(60),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : (isAvailable
                          ? (isBusiness
                              ? Icons.airline_seat_recline_extra
                              : Icons.event_seat_rounded)
                          : Icons.block_rounded),
                  size: 20,
                  color: iconColor,
                ),
                const SizedBox(height: 2),
                Text(
                  seat.seatNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '৳${seat.price.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withAlpha(220)
                        : (isAvailable
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline),
                    fontSize: 8.5,
                    fontWeight: isAvailable ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
