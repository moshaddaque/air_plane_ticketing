import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/flight_route.dart';

class RouteHorizontalCard extends StatelessWidget {
  final FlightRoute route;
  final bool selected;
  final VoidCallback onTap;

  const RouteHorizontalCard({
    super.key,
    required this.route,
    required this.selected,
    required this.onTap,
  });

  String _imageUrl(String path) {
    final value = path.trim();
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    return Uri.parse('${ApiConstants.baseUrl}/').resolve(value).toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = _imageUrl(route.imageUrl);

    Widget fallback() => ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.flight_rounded,
        color: theme.colorScheme.primary,
        size: 28,
      ),
    );

    return SizedBox(
      width: 224,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: selected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 1.5 : 0.7,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                width: double.infinity,
                child: image.isEmpty
                    ? fallback()
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => fallback(),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.originCode}  →  ${route.destinationCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: selected ? theme.colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${route.origin} → ${route.destination}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined, size: 15),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            route.durationMinutes > 0
                                ? '${route.durationMinutes ~/ 60}h ${route.durationMinutes % 60}m'
                                : 'Duration unavailable',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        if (route.distanceKm > 0)
                          Text(
                            '${route.distanceKm.toStringAsFixed(0)} km',
                            style: theme.textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
