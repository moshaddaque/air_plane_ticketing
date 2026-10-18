import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/seat.dart';
import '../../domain/repositories/seats_repository.dart';

enum SeatSelectionResult {
  selected,
  deselected,
  notAvailable,
}

class SeatsProvider extends ChangeNotifier {
  final SeatsRepository _repository;

  SeatsProvider(this._repository);

  List<Seat> _seats = [];
  bool _isLoading = false;
  int? _currentTripId;
  String? _errorMessage;
  Seat? _selectedSeat;
  String _classFilter = 'all';

  List<Seat> get seats => List.unmodifiable(_seats);
  bool get isLoading => _isLoading;
  int? get currentTripId => _currentTripId;
  String? get errorMessage => _errorMessage;
  Seat? get selectedSeat => _selectedSeat;
  String get classFilter => _classFilter;

  int get totalSeatsCount => _seats.length;
  int get availableSeatsCount =>
      _seats.where((seat) => seat.isAvailable).length;
  int get bookedSeatsCount =>
      _seats.where((seat) => !seat.isAvailable).length;

  List<String> get availableClasses {
    final classes = _seats.map((s) => s.seatClass.toLowerCase()).toSet().toList();
    classes.sort();
    return classes;
  }

  List<Seat> get filteredSeats {
    if (_classFilter == 'all') {
      return List.unmodifiable(_seats);
    }
    return _seats
        .where((s) => s.seatClass.toLowerCase() == _classFilter.toLowerCase())
        .toList();
  }

  Future<void> loadSeats(int tripId, {bool force = false}) async {
    if (_isLoading) return;
    if (!force && _currentTripId == tripId && _seats.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _selectedSeat = null;
    _classFilter = 'all';
    _currentTripId = tripId;
    notifyListeners();

    try {
      _seats = await _repository.getSeatsByTrip(tripId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _seats = [];
    } catch (e, stackTrace) {
      debugPrint('Load seats failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to load seats. Please try again.';
      _seats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  SeatSelectionResult toggleSeatSelection(Seat seat) {
    if (!seat.isAvailable) {
      return SeatSelectionResult.notAvailable;
    }

    if (_selectedSeat?.id == seat.id) {
      _selectedSeat = null;
      notifyListeners();
      return SeatSelectionResult.deselected;
    }

    _selectedSeat = seat;
    notifyListeners();
    return SeatSelectionResult.selected;
  }

  void clearSelection() {
    _selectedSeat = null;
    notifyListeners();
  }

  void setClassFilter(String filter) {
    if (_classFilter != filter) {
      _classFilter = filter;
      notifyListeners();
    }
  }
}
