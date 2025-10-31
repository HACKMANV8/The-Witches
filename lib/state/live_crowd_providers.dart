import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:metropulse/models/crowd_report_model.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/services/crowd_report_service.dart';
import 'package:metropulse/services/station_service.dart';
import 'package:metropulse/widgets/crowd_badge.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:metropulse/supabase/supabase_config.dart';

/// Provides full station list for mapping.
final stationsProvider = FutureProvider<List<StationModel>>((ref) async {
  return StationService.getAllStations();
});

/// Realtime stream of recent reports (sliding 15-minute window).
final liveReportsProvider = StreamProvider<List<CrowdReportModel>>((ref) {
  return CrowdReportService.streamRecentReports();
});

/// Trigger refresh every 5 minutes
final routeRefreshTickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(minutes: 5), (i) => i);
});

/// Stream of aggregated crowd level per station (maps stationId -> CrowdLevel).
final stationCrowdStreamProvider = StreamProvider<Map<String, CrowdLevel>>((ref) {
  // Watch refresh timer to force re-computation
  ref.watch(routeRefreshTickProvider);
  return CrowdReportService.streamRecentReports().map((reports) {
    final Map<String, List<CrowdLevel>> stationToLevels = {};
    for (final report in reports) {
      stationToLevels.putIfAbsent(report.stationId, () => <CrowdLevel>[]).add(CrowdReportModel.toUiLevel(report.crowdLevelValue));
    }

    CrowdLevel levelFromAverage(double avg) {
      if (avg <= 1.5) return CrowdLevel.low;
      if (avg <= 2.3) return CrowdLevel.moderate;
      return CrowdLevel.high;
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
});

/// Aggregated live crowd level per station (avg over last 15 minutes).
final aggregatedCrowdByStationProvider = Provider<Map<String, CrowdLevel>>((ref) {
  final streamVal = ref.watch(stationCrowdStreamProvider);
  final base = streamVal.maybeWhen(data: (m) => m, orElse: () => <String, CrowdLevel>{});
  // Merge in any short-lived local optimistic overrides (submitted reports not yet reflected in the stream)
  final overridesAsync = ref.watch(localCrowdOverridesProvider);
  final overrides = overridesAsync.maybeWhen(data: (m) => m, orElse: () => <String, CrowdLevel>{});
  return {...base, ...overrides};
});

/// Aggregated live crowd level per station broken down by coach position (if reports include coach_position).
/// Map: stationId -> (coachPosition -> CrowdLevel)
final aggregatedCrowdByStationCoachProvider = Provider<Map<String, Map<String, CrowdLevel>>>((ref) {
  final reportsAsync = ref.watch(liveReportsProvider);
  final reports = reportsAsync.maybeWhen(data: (r) => r, orElse: () => <CrowdReportModel>[]);

  final Map<String, Map<String, CrowdLevel>> out = {};
  for (final r in reports) {
    final coach = r.coachPosition;
    if (coach == null) continue;
    final sid = r.stationId;
    final lvl = CrowdReportModel.toUiLevel(r.crowdLevelValue);
    out.putIfAbsent(sid, () => <String, CrowdLevel>{})[coach] = lvl;
  }

  return out;
});

/// Local short-lived crowd overrides applied optimistically when a user submits a report.

// Use a broadcast StreamController to publish local override maps so providers can watch it.
final Map<String, CrowdLevel> _localCrowdOverrides = {};
final Map<String, Timer> _localCrowdTimers = {};
final _localCrowdOverridesController = StreamController<Map<String, CrowdLevel>>.broadcast();

final localCrowdOverridesProvider = StreamProvider<Map<String, CrowdLevel>>((ref) {
  // Start by emitting current state and also watch live reports so we can
  // automatically remove optimistic overrides when a matching real report
  // appears in the stream (so the optimistic override doesn't linger).
  // Note: do not close the global controller on dispose because it's shared
  // for the app lifetime.
  // Listen to the real-time recent reports stream and remove any overrides
  // whose station + ui level matches a newly arrived report.
  ref.listen<AsyncValue<List<CrowdReportModel>>>(
    liveReportsProvider,
    (previous, next) {
      next.when(
        data: (reports) {
          var didChange = false;
          for (final r in reports) {
            final sid = r.stationId;
            final uiLevel = CrowdReportModel.toUiLevel(r.crowdLevelValue);
            final current = _localCrowdOverrides[sid];
            if (current != null && current == uiLevel) {
              // cancel any timer and remove override
              _localCrowdTimers[sid]?.cancel();
              _localCrowdTimers.remove(sid);
              _localCrowdOverrides.remove(sid);
              didChange = true;
            }
          }
          if (didChange) {
            _localCrowdOverridesController.add(Map<String, CrowdLevel>.from(_localCrowdOverrides));
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    },
  );

  ref.onDispose(() {
    // do not close the global controller (shared across app)
  });

  // emit current state as the stream's initial values will be produced by the controller
  return _localCrowdOverridesController.stream;
});

void addLocalCrowdOverride(String stationId, CrowdLevel level, {Duration ttl = const Duration(seconds: 30)}) {
  // cancel existing timer if present
  _localCrowdTimers[stationId]?.cancel();
  _localCrowdOverrides[stationId] = level;
  _localCrowdOverridesController.add(Map<String, CrowdLevel>.from(_localCrowdOverrides));
  _localCrowdTimers[stationId] = Timer(ttl, () {
    _localCrowdTimers.remove(stationId);
    _localCrowdOverrides.remove(stationId);
    _localCrowdOverridesController.add(Map<String, CrowdLevel>.from(_localCrowdOverrides));
  });
}

/// Provide current device location (if permission granted). Returns null on failure.
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    return null;
  }
});

double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000; // metres
  final phi1 = lat1 * (3.141592653589793 / 180);
  final phi2 = lat2 * (3.141592653589793 / 180);
  final dphi = (lat2 - lat1) * (3.141592653589793 / 180);
  final dlambda = (lon2 - lon1) * (3.141592653589793 / 180);
  final a = (sin(dphi / 2) * sin(dphi / 2)) +
      cos(phi1) * cos(phi2) * (sin(dlambda / 2) * sin(dlambda / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

/// Recommended stations as a FutureProvider: returns up to 5 stations sorted by
/// a weighted score of crowdLevel (live or predicted) and distance (if available).
final recommendedStationsProvider = FutureProvider.family<List<StationModel>, String>((ref, stationId) async {
  final stations = await StationService.getAllStations();
  final aggregated = ref.watch(aggregatedCrowdByStationProvider);
  final pos = await ref.watch(currentLocationProvider.future);

  // Fetch predicted crowds (latest per station) if available
  Map<String, double> predictedMap = {};
  try {
    final preds = await SupabaseService.select('predicted_crowds');
    for (final p in preds) {
      final sid = p['station_id'] as String?;
      final val = (p['predicted_level'] as num?)?.toDouble();
      if (sid != null && val != null) predictedMap[sid] = val;
    }
  } catch (e) {
    // no predicted data available; ignore
  }

  // Build candidates excluding the origin station
  final candidates = stations.where((s) => s.id != stationId && s.latitude != null && s.longitude != null).toList();

  // Score: lower is better. We'll compute normalized crowd score (1..3) and distance in meters.
  double crowdScore(String id) {
    // prefer predicted, then aggregated, then default 2
    if (predictedMap.containsKey(id)) {
      final p = predictedMap[id]!; // assume 1..5 scale
      // map to 1..3
      if (p <= 2) return 1.0;
      if (p <= 3) return 2.0;
      return 3.0;
    }
    final lvl = aggregated[id];
    if (lvl == null) return 2.0;
    return lvl == CrowdLevel.low ? 1.0 : lvl == CrowdLevel.moderate ? 2.0 : 3.0;
  }

  // compute score and sort
  final scored = <MapEntry<StationModel, double>>[];
  for (final s in candidates) {
    final lat = s.latitude!;
    final lng = s.longitude!;
    final dist = (pos == null) ? 10000.0 : _haversineDistance(pos.latitude, pos.longitude, lat, lng);
    final cscore = crowdScore(s.id);
    // normalize distance to [0,1] by dividing by 10km (10000 m) and clamp
    final nd = (dist / 10000.0).clamp(0.0, 1.0);
    // normalize crowd to [0,1] where lower crowd => 0, higher => 1 (crowd 1->0, 3->1)
    final nc = ((cscore - 1.0) / 2.0).clamp(0.0, 1.0);
    // weighted: 60% crowd, 40% distance (lower better)
    final score = 0.6 * nc + 0.4 * nd;
    scored.add(MapEntry(s, score));
  }

  scored.sort((a, b) => a.value.compareTo(b.value));
  return scored.map((e) => e.key).take(5).toList();
});

// (The improved recommendedStationsProvider above replaces the simple one.)


