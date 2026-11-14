import '../models/telemetry.dart';

abstract class ITelemetryRepository {
  Future<TelemetryData> getTelemetryForQuery({String? queryId});
}
