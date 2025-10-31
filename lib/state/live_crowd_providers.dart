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
    stationToLevels
        .putIfAbsent(report.stationId, () => <CrowdLevel>[]) 
        .add(CrowdReportModel.toUiLevel(report.crowdLevelValue));
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

/// Simple recommendation provider: for a given stationId, return up to [limit]
/// nearby/alternative stations sorted by crowd level ascending (less crowded first).
/// Currently 'nearby' is approximated by returning other stations; this can be
/// improved with geospatial distance if location is available.
final recommendedStationsProvider = Provider.family<List<StationModel>, String>((ref, stationId) {
  final stationsAsync = ref.watch(stationsProvider);
  final aggregated = ref.watch(aggregatedCrowdByStationProvider);

  final stations = stationsAsync.maybeWhen(data: (s) => s, orElse: () => const <StationModel>[]);
  // Exclude the same station and sort by crowd level (unknown -> last)
  final List<StationModel> candidates = stations.where((s) => s.id != stationId).toList();

  candidates.sort((a, b) {
    final la = aggregated[a.id];
    final lb = aggregated[b.id];
    if (la == null && lb == null) return 0;
    if (la == null) return 1;
    if (lb == null) return -1;
    int va = la == CrowdLevel.low ? 1 : la == CrowdLevel.moderate ? 2 : 3;
    int vb = lb == CrowdLevel.low ? 1 : lb == CrowdLevel.moderate ? 2 : 3;
    return va.compareTo(vb);
  });

  return candidates.take(5).toList();
});


