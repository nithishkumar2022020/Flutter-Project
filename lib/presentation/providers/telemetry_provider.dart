import 'package:flutter/foundation.dart';
import '../../domain/models/telemetry.dart';
import '../../domain/repositories/i_telemetry_repository.dart';

class TelemetryProvider extends ChangeNotifier {
  final ITelemetryRepository _repository;
  TelemetryData? _telemetry;
  bool _isLoading = false;

  TelemetryProvider({required ITelemetryRepository repository})
    : _repository = repository {
    fetchLatestTelemetry();
  }

  TelemetryData? get telemetry => _telemetry;
  bool get isLoading => _isLoading;

  Future<void> fetchLatestTelemetry({String? queryId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _telemetry = await _repository.getTelemetryForQuery(queryId: queryId);
    } catch (_) {
      _telemetry = TelemetryData.mock();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
