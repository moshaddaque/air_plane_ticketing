import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/flight_route.dart';
import '../../domain/repositories/routes_repository.dart';

class RoutesProvider extends ChangeNotifier {
  final RoutesRepository _repository;

  RoutesProvider(this._repository);

  List<FlightRoute> _routes = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<FlightRoute> get routes => List.unmodifiable(_routes);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoutes({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routes = await _repository.getRoutes();
      _hasLoaded = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('Load routes failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to load routes. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
