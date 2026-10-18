import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/trip.dart';
import '../../../routes/domain/entities/flight_route.dart';
import '../../../routes/presentation/providers/routes_provider.dart';
import '../../../routes/presentation/widgets/route_horizontal_card.dart';
import '../providers/trips_provider.dart';
import '../widgets/trip_card.dart';
import 'trip_details_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});
  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  DateTime? _date;
  bool _loadedInitially = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedInitially) return;
    _loadedInitially = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TripsProvider>().loadTrips();
        context.read<RoutesProvider>().loadRoutes();
      }
    });
  }

  @override
  void dispose() { _origin.dispose(); _destination.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context, initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2), helpText: 'Select departure date',
    );
    if (result != null && mounted) setState(() => _date = result);
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<TripsProvider>().searchTrips(
      originCode: _origin.text, destinationCode: _destination.text, date: _date,
    );
  }

  Future<void> _clear() async {
    _origin.clear(); _destination.clear(); setState(() => _date = null);
    await context.read<TripsProvider>().clearSearch();
  }

  Future<void> _selectRoute(FlightRoute route) async {
    _origin.text = route.originCode;
    _destination.text = route.destinationCode;
    FocusScope.of(context).unfocus();
    await context.read<TripsProvider>().searchTrips(
      originCode: route.originCode,
      destinationCode: route.destinationCode,
      date: _date,
    );
  }

  Future<void> _details(Trip trip) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TripDetailsScreen(tripId: trip.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TripsProvider>();
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => p.isSearching
        ? p.searchTrips(originCode: p.originCode, destinationCode: p.destinationCode, date: p.selectedDate)
        : p.loadTrips(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text('Find your flight', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Search available trips and compare flights.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Card(
            elevation: 0, color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Row(children: [
                    Expanded(child: TextFormField(
                      controller: _origin, textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'From', hintText: 'DAC',
                        prefixIcon: Icon(Icons.flight_takeoff), border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter origin code' : null,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(
                      controller: _destination, textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.search, onFieldSubmitted: (_) => _search(),
                      decoration: const InputDecoration(labelText: 'To', hintText: 'CXB',
                        prefixIcon: Icon(Icons.flight_land), border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter destination';
                        if (v.trim().toUpperCase() == _origin.text.trim().toUpperCase()) return 'Choose another destination';
                        return null;
                      },
                    )),
                  ]),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate, borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Departure date (optional)',
                        prefixIcon: Icon(Icons.calendar_month_outlined), border: OutlineInputBorder()),
                      child: Row(children: [
                        Expanded(child: Text(_date == null ? 'Any date' :
                          '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}')),
                        if (_date != null) IconButton(onPressed: () => setState(() => _date = null),
                          icon: const Icon(Icons.close), tooltip: 'Clear date'),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: FilledButton.icon(
                      onPressed: p.isLoading ? null : _search,
                      icon: const Icon(Icons.search), label: const Text('Search flights'))),
                    if (p.isSearching) ...[
                      const SizedBox(width: 8),
                      IconButton(onPressed: p.isLoading ? null : _clear,
                        tooltip: 'Clear search', icon: const Icon(Icons.restart_alt)),
                    ],
                  ]),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _RoutesSection(
            onRouteSelected: _selectRoute,
            selectedOrigin: p.originCode,
            selectedDestination: p.destinationCode,
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Text(p.isSearching ? 'Search results' : 'Available trips',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
            if (!p.isSearching) Text('${p.trips.length} flights', style: theme.textTheme.bodySmall),
          ]),
          const SizedBox(height: 12),
          if (p.isLoading && p.trips.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
          else if (p.errorMessage != null && p.trips.isEmpty)
            _EmptyState(icon: Icons.cloud_off_outlined, title: 'Could not load trips',
              message: p.errorMessage!, button: 'Try again',
              onPressed: () => p.isSearching
                ? p.searchTrips(originCode: p.originCode, destinationCode: p.destinationCode, date: p.selectedDate)
                : p.loadTrips(force: true))
          else if (p.trips.isEmpty)
            _EmptyState(icon: Icons.flight_outlined,
              title: p.isSearching ? 'No flights found' : 'No trips yet',
              message: p.isSearching ? 'Try other airport codes or a different date.' : 'Available trips will appear here.',
              button: p.isSearching ? 'Clear search' : 'Refresh',
              onPressed: p.isSearching ? _clear : () => p.loadTrips(force: true))
          else ...[
            if (p.isLoading) const LinearProgressIndicator(),
            ...p.trips.map((trip) => TripCard(trip: trip, onTap: () => _details(trip))),
          ],
        ],
      ),
    );
  }
}


class _RoutesSection extends StatelessWidget {
  final Future<void> Function(FlightRoute route) onRouteSelected;
  final String selectedOrigin;
  final String selectedDestination;

  const _RoutesSection({
    required this.onRouteSelected,
    required this.selectedOrigin,
    required this.selectedDestination,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutesProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Popular routes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (provider.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Choose a route to see available flights.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (provider.errorMessage != null && provider.routes.isEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => provider.loadRoutes(force: true),
                child: const Text('Retry'),
              ),
            ],
          )
        else if (provider.routes.isEmpty && !provider.isLoading)
          const Text('No routes available right now.')
        else
          SizedBox(
            height: 224,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.routes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final route = provider.routes[index];
                final selected = route.originCode.toUpperCase() ==
                        selectedOrigin.toUpperCase() &&
                    route.destinationCode.toUpperCase() ==
                        selectedDestination.toUpperCase();

                return RouteHorizontalCard(
                  route: route,
                  selected: selected,
                  onTap: () => onRouteSelected(route),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message, button;
  final VoidCallback onPressed;
  const _EmptyState({required this.icon, required this.title, required this.message, required this.button, required this.onPressed});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
    child: Column(children: [
      Icon(icon, size: 44, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6), Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 14), OutlinedButton(onPressed: onPressed, child: Text(button)),
    ]),
  );
}
