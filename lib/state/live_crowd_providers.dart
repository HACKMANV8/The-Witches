import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/models/crowd_report_model.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/services/crowd_report_service.dart';
import 'package:metropulse/services/station_service.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

/// Provides full station list for mapping.
final stationsProvider = FutureProvider<List<StationModel>>((ref) async {
  return StationService.getAllStations();
});

/// Realtime stream of recent reports (sliding 15-minute window).
final liveReportsProvider = StreamProvider<List<CrowdReportModel>>((ref) {
  return CrowdReportService.streamRecentReports();
});

/// Aggregated live crowd level per station (avg over last 15 minutes).
final aggregatedCrowdByStationProvider = Provider<Map<String, CrowdLevel>>((ref) {
  final reports = ref.watch(liveReportsProvider).maybeWhen(data: (r) => r, orElse: () => const <CrowdReportModel>[]);

  final Map<String, List<CrowdLevel>> stationToLevels = {};
  for (final report in reports) {
    stationToLevels.putIfAbsent(report.stationId, () => <CrowdLevel>[]).add(report.crowdLevel);
  }

  CrowdLevel levelFromAverage(double avg) {
    if (avg <= 1.5) return CrowdLevel.low; // mostly 1s
    if (avg <= 2.3) return CrowdLevel.moderate; // mixed 2s
    return CrowdLevel.high; // mostly 3s
  }

  final Map<String, CrowdLevel> result = {};
  for (final entry in stationToLevels.entries) {
    final values = entry.value;
    if (values.isEmpty) continue;
    final numeric = values.map((e) => switch (e) { CrowdLevel.low => 1, CrowdLevel.moderate => 2, CrowdLevel.high => 3 });
    final avg = numeric.reduce((a, b) => a + b) / values.length;
    result[entry.key] = levelFromAverage(avg);
  }
  return result;
});


