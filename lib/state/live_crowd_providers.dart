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

/// Predicted crowd level per station based on historical data and time of day
final predictedCrowdProvider = FutureProvider.autoDispose<Map<String, CrowdLevel>>((ref) async {
  // Use requestedAt to determine hour of day and day of week
  final now = DateTime.now();
  final weekday = now.weekday; // 1 = Monday, 7 = Sunday
  final hour = now.hour;
  
  // Query Supabase predicted_crowds table filtered by weekday and hour
  final hourRange = '${hour.toString().padLeft(2, '0')}:00-${(hour+1).toString().padLeft(2, '0')}:00';
  
  final response = await SupabaseConfig.client
    .from('predicted_crowds')
    .select()
    .eq('weekday', weekday)
    .eq('hour_range', hourRange);
    
  final data = response as List<dynamic>;
  
  // Map to crowd levels based on predicted values
  final Map<String, CrowdLevel> levels = {};
  for (final row in data) {
    final stationId = row['station_id']?.toString();
    if (stationId == null) continue;
    
    final crowdScore = (row['crowd_score'] ?? 0.0) as num;
    final level = switch (crowdScore) {
      < 0.33 => CrowdLevel.low,
      < 0.66 => CrowdLevel.moderate,
      _ => CrowdLevel.high
    };
    levels[stationId] = level;
  }
  
  return levels;
});

/// Stream of aggregated crowd level per station (maps stationId -> CrowdLevel).
final stationCrowdStreamProvider = StreamProvider<Map<String, CrowdLevel>>((ref) {
  // Watch refresh timer to force re-computation
  ref.watch(routeRefreshTickProvider);
  
  final predictedAsync = ref.watch(predictedCrowdProvider);
  final predicted = predictedAsync.value ?? const <String, CrowdLevel>{};
  
  return CrowdReportService.streamRecentReports().map((reports) {
    final Map<String, List<CrowdLevel>> stationToLevels = {};
    
    // First, incorporate predicted levels (lower weight)
    for (final entry in predicted.entries) {
      final level = entry.value;
      stationToLevels.putIfAbsent(entry.key, () => <CrowdLevel>[])
        .addAll([level, level]); // Add twice to give it some weight
    }
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
  // Combine live-reports-derived coach map with any local coach overrides for dev/optimistic view.
  final reportsAsync = ref.watch(liveReportsProvider);
  final reports = reportsAsync.maybeWhen(data: (r) => r, orElse: () => <CrowdReportModel>[]);
  final localAsync = ref.watch(localCoachOverridesProvider);
  final local = localAsync.maybeWhen(data: (m) => m, orElse: () => <String, Map<String, CrowdLevel>>{});

  final Map<String, Map<String, CrowdLevel>> out = {};
  for (final r in reports) {
    final coach = r.coachPosition;
    if (coach == null) continue;
    final sid = r.stationId;
    final lvl = CrowdReportModel.toUiLevel(r.crowdLevelValue);
    final tokens = coach.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    for (final t in tokens) {
      out.putIfAbsent(sid, () => <String, CrowdLevel>{})[t] = lvl;
    }
  }

  // merge local overrides (take precedence)
  for (final entry in local.entries) {
    final sid = entry.key;
    final map = entry.value;
    for (final cEntry in map.entries) {
      out.putIfAbsent(sid, () => <String, CrowdLevel>{})[cEntry.key] = cEntry.value;
    }
  }

  return out;
});

/// Local short-lived crowd overrides applied optimistically when a user submits a report.

// Use a broadcast StreamController to publish local override maps so providers can watch it.
final Map<String, CrowdLevel> _localCrowdOverrides = {};
final Map<String, Timer> _localCrowdTimers = {};
final _localCrowdOverridesController = StreamController<Map<String, CrowdLevel>>.broadcast();

// Local coach-level overrides (dev / optimistic view). Map: stationId -> coachId -> CrowdLevel
final Map<String, Map<String, CrowdLevel>> _localCoachOverrides = {};
final Map<String, Map<String, Timer>> _localCoachTimers = {};
final _localCoachOverridesController = StreamController<Map<String, Map<String, CrowdLevel>>>.broadcast();

final localCoachOverridesProvider = StreamProvider<Map<String, Map<String, CrowdLevel>>>((ref) {
  // do not close shared controller on dispose
  ref.onDispose(() {});
  return _localCoachOverridesController.stream;
});

/// Add a local coach-level override (dev / optimistic). coachId is a string token
/// (e.g., '0' or 'rear') and ttl controls how long the override lasts.
void addLocalCoachOverride(String stationId, String coachId, CrowdLevel level, {Duration ttl = const Duration(seconds: 30)}) {
  _localCoachTimers.putIfAbsent(stationId, () => {})[coachId]?.cancel();
  _localCoachOverrides.putIfAbsent(stationId, () => {})[coachId] = level;
  _localCoachOverridesController.add(Map.fromEntries(_localCoachOverrides.entries.map((e) => MapEntry(e.key, Map<String, CrowdLevel>.from(e.value)))));
  _localCoachTimers.putIfAbsent(stationId, () => {})[coachId] = Timer(ttl, () {
    _localCoachTimers[stationId]?.remove(coachId);
    _localCoachOverrides[stationId]?.remove(coachId);
    if (_localCoachOverrides[stationId]?.isEmpty ?? false) _localCoachOverrides.remove(stationId);
    _localCoachOverridesController.add(Map.fromEntries(_localCoachOverrides.entries.map((e) => MapEntry(e.key, Map<String, CrowdLevel>.from(e.value)))));
  });
}

/// Dev helper: seed a few sample coach overrides for the first N stations so coach markers
/// are visible without needing backend reports. This is intended for development only.
Future<void> seedSampleCoachOverrides({int count = 5}) async {
  try {
    final stations = await StationService.getAllStations();
    final take = stations.take(count).toList();
    for (var i = 0; i < take.length; i++) {
      final s = take[i];
      if (s.latitude == null || s.longitude == null) continue;
      // set coach 0 as low, coach 1 as moderate, coach 2 as high in a pattern
      addLocalCoachOverride(s.id, '0', CrowdLevel.low, ttl: const Duration(minutes: 5));
      addLocalCoachOverride(s.id, '1', CrowdLevel.moderate, ttl: const Duration(minutes: 5));
      addLocalCoachOverride(s.id, '2', CrowdLevel.high, ttl: const Duration(minutes: 5));
    }
  } catch (_) {}
}

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
/// Request object for recommended stations calculation.
class RecommendedStationsRequest {
  final String fromStationId;
  final DateTime requestedAt;
  const RecommendedStationsRequest({required this.fromStationId, required this.requestedAt});
}

/// Recommended stations provider that considers predicted crowds for the requested day/time.
final recommendedStationsProvider = FutureProvider.family<List<StationModel>, RecommendedStationsRequest>((ref, req) async {
  final stations = await StationService.getAllStations();
  final aggregated = ref.watch(aggregatedCrowdByStationProvider);
  final pos = await ref.watch(currentLocationProvider.future);

  // Fetch predicted crowds (latest per station) if available. We'll filter predictions for day and hour.
  List<Map<String, dynamic>> preds = [];
  try {
    final raw = await SupabaseService.select('predicted_crowds');
    preds = List<Map<String, dynamic>>.from(raw.map((r) => Map<String, dynamic>.from(r)));
  } catch (e) {
    preds = [];
  }

  // Helper to find predicted value for a station matching the requested day/hour
  double? findPredictedForStation(String stationId) {
    final weekday = _weekdayName(req.requestedAt.weekday);
    final hour = req.requestedAt.hour;
    // Search preds for matching station and day and hour-range containing hour
    for (final p in preds) {
      String? sid = p['station_id'] as String? ?? p['station'] as String?;
      if (sid == null) continue;
      if (sid != stationId) continue;
      final day = p['day'] as String? ?? p['weekday'] as String?;
      if (day == null) continue;
      if (day.toLowerCase() != weekday.toLowerCase()) continue;
      final range = p['hour_range'] as String? ?? p['time_range'] as String? ?? p['hour'] as String?;
      if (range == null) continue;
      // parse '04:00-05:00'
      final parts = range.split('-');
      if (parts.length != 2) continue;
      try {
        final start = int.parse(parts[0].split(':').first);
        final end = int.parse(parts[1].split(':').first);
        if (hour >= start && hour < end) {
          final val = (p['predicted_level'] as num?)?.toDouble() ?? (p['level'] as num?)?.toDouble();
          return val;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Build candidates excluding the origin station
  final candidates = stations.where((s) => s.id != req.fromStationId && s.latitude != null && s.longitude != null).toList();

  // Precompute predicted map and fallback interpolation using nearest predicted station
  final Map<String, double?> predictedMap = {};
  for (final s in stations) {
    predictedMap[s.id] = findPredictedForStation(s.id);
  }

  // For stations missing predicted, fill with nearest station's predicted value if available
  for (final s in stations) {
    if (predictedMap[s.id] == null) {
      // find nearest station with a predicted value
      double? bestVal;
      double bestDist = double.infinity;
      for (final other in stations) {
        if (predictedMap[other.id] == null) continue;
        if (other.latitude == null || other.longitude == null || s.latitude == null || s.longitude == null) continue;
        final d = _haversineDistance(s.latitude!, s.longitude!, other.latitude!, other.longitude!);
        if (d < bestDist) {
          bestDist = d;
          bestVal = predictedMap[other.id];
        }
      }
      predictedMap[s.id] = bestVal ?? 2.0; // default to moderate if none available
    }
  }

  // Score: lower is better. We'll compute normalized crowd score (1..3) and distance (if available).
  double crowdScore(String id) {
    final p = predictedMap[id];
    if (p != null) {
      // map predicted numeric value to 1..3
      if (p <= 2.0) return 1.0;
      if (p <= 3.0) return 2.0;
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

String _weekdayName(int weekday) {
  // DateTime.weekday: 1=Mon .. 7=Sun. Map to common names.
  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
    default:
      return 'Sunday';
  }
}

// (The improved recommendedStationsProvider above replaces the simple one.)


