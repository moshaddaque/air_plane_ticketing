import 'package:flutter/foundation.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trips_repository.dart';

class TripsProvider extends ChangeNotifier {
  final TripsRepository _repository;
  TripsProvider(this._repository);

  List<Trip> _trips = [];
  bool _isLoading = false, _hasLoaded = false;
  String? _errorMessage;
  String _origin = '', _destination = '';
  DateTime? _date;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  String get originCode => _origin;
  String get destinationCode => _destination;
  DateTime? get selectedDate => _date;
  bool get isSearching => _origin.isNotEmpty && _destination.isNotEmpty;

  Future<void> loadTrips({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force && !isSearching)) return;
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      _trips = await _repository.getTrips();
      _hasLoaded = true; _origin = ''; _destination = ''; _date = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e, st) {
      debugPrint('Load trips failed: $e'); debugPrintStack(stackTrace: st);
      _errorMessage = 'Unable to load trips. Please try again.';
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> searchTrips({
    required String originCode,
    required String destinationCode,
    DateTime? date,
  }) async {
    final origin = originCode.trim().toUpperCase();
    final destination = destinationCode.trim().toUpperCase();
    if (origin.isEmpty || destination.isEmpty) {
      _errorMessage = 'Enter both origin and destination airport codes.';
      notifyListeners(); return;
    }
    if (origin == destination) {
      _errorMessage = 'Origin and destination must be different.';
      notifyListeners(); return;
    }
    _isLoading = true; _errorMessage = null;
    _origin = origin; _destination = destination; _date = date; notifyListeners();
    try {
      _trips = await _repository.searchTrips(
        originCode: origin, destinationCode: destination, date: date,
      );
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message; _trips = [];
    } catch (e, st) {
      debugPrint('Search trips failed: $e'); debugPrintStack(stackTrace: st);
      _errorMessage = 'Trip search failed. Please try again.'; _trips = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<Trip?> fetchTripDetails(int id) async {
    _errorMessage = null;
    try {
      return await _repository.getTripDetails(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e, st) {
      debugPrint('Trip details failed: $e'); debugPrintStack(stackTrace: st);
      _errorMessage = 'Unable to load trip details.';
    }
    notifyListeners(); return null;
  }

  Future<void> clearSearch() async {
    _origin = ''; _destination = ''; _date = null;
    await loadTrips(force: true);
  }
}
