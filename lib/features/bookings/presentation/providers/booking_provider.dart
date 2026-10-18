import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;

  BookingProvider(this._repository);

  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isBooking = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _bookingError;
  Booking? _lastCreatedBooking;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  String? get bookingError => _bookingError;
  Booking? get lastCreatedBooking => _lastCreatedBooking;

  Future<void> loadMyBookings({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _repository.getMyBookings();
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Load my bookings failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to load your bookings. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking?> createBooking({
    required int tripId,
    required int seatId,
    int? passengerId,
  }) async {
    if (_isBooking) return null;

    _isBooking = true;
    _bookingError = null;
    notifyListeners();

    try {
      final booking = await _repository.createBooking(
        tripId: tripId,
        seatId: seatId,
        passengerId: passengerId,
      );

      _lastCreatedBooking = booking;
      // Prepend to current bookings so the list updates immediately
      _bookings = [booking, ..._bookings.where((b) => b.id != booking.id)];

      return booking;
    } on ApiException catch (e) {
      _bookingError = e.message;
      return null;
    } catch (e, stackTrace) {
      debugPrint('Create booking failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _bookingError = 'Booking failed. Please try again.';
      return null;
    } finally {
      _isBooking = false;
      notifyListeners();
    }
  }

  void clearBookingError() {
    _bookingError = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _bookingError = null;
    notifyListeners();
  }
}
