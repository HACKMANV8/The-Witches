// material import not needed here
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show sin, cos;
import 'package:flutter/widgets.dart' show Offset;
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

/// Cache BitmapDescriptor icons for marker colors to avoid rebuilding them
final _markerIconCache = <CrowdLevel, BitmapDescriptor>{};

/// Value class to hold markers and their current alpha for smooth transitions
class MarkerUpdate {
  final Set<Marker> markers;
  final double alpha;
  MarkerUpdate(this.markers, this.alpha);
}

/// Manager class for marker state with smooth transitions
class MapMarkerStateManager {
  MarkerUpdate _state = MarkerUpdate(<Marker>{}, 1.0);
  MarkerUpdate get current => _state;

  /// Update markers with a smooth transition based on new crowd levels
  /// Update markers with a smooth transition based on new crowd levels.
  /// If [showCoach] is true and [coachLevels] is provided, small per-coach markers
  /// will be rendered around the station location.
  Future<MarkerUpdate> updateMarkers(
    List<StationModel> stations,
    Map<String, CrowdLevel> crowdLevels, {
    Map<String, Map<String, CrowdLevel>>? coachLevels,
    bool showCoach = false,
    String? highlightedStationId,
  }) async {
    // First fade out existing markers
    for (var i = 10; i > 0; i--) {
      final alpha = i / 10.0;
      _state = MarkerUpdate(_state.markers, alpha);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final newMarkers = <Marker>{};
    for (final station in stations) {
      if (station.latitude == null || station.longitude == null) continue;
      final level = crowdLevels[station.id] ?? CrowdLevel.low;
      final hue = switch (level) {
        CrowdLevel.low => BitmapDescriptor.hueGreen,
        CrowdLevel.moderate => BitmapDescriptor.hueYellow,
        CrowdLevel.high => BitmapDescriptor.hueRed,
      };

      // Use cached icon or create a new one
      if (!_markerIconCache.containsKey(level)) {
        _markerIconCache[level] = BitmapDescriptor.defaultMarkerWithHue(hue);
      }
      final icon = _markerIconCache[level]!;

      // Add the station-level marker
      // Decide zIndex to bring highlighted station to the front
      final z = (highlightedStationId != null && highlightedStationId == station.id) ? 2 : 1;
      newMarkers.add(Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude!, station.longitude!),
        infoWindow: InfoWindow(title: station.name, snippet: level.label),
        icon: icon,
        alpha: 0.0, // Start invisible for fade-in
        zIndexInt: z,
      ));

      // If coach-level view is requested and we have coach data for this station,
      // render small offset markers (one per coach) colored by their coach-level.
      if (showCoach && coachLevels != null) {
        final coaches = coachLevels[station.id];
        if (coaches != null && coaches.isNotEmpty) {
          // spread coaches in a small circle around the station (approx offsets)
          final entries = coaches.entries.toList();
          final count = entries.length;
          for (var i = 0; i < count; i++) {
            final angle = (2 * 3.141592653589793 * i) / count;
            // ~10 meters offset
            const offsetMeters = 12.0;
            final dLat = (offsetMeters / 111320.0) * cos(angle);
            final dLng = (offsetMeters / (111320.0 * cos(station.latitude! * (3.141592653589793 / 180)))) * sin(angle);
            final coachPos = LatLng(station.latitude! + dLat, station.longitude! + dLng);
            final coachLevel = entries[i].value;
            final coachHue = switch (coachLevel) {
              CrowdLevel.low => BitmapDescriptor.hueGreen,
              CrowdLevel.moderate => BitmapDescriptor.hueYellow,
              CrowdLevel.high => BitmapDescriptor.hueRed,
            };
            final coachIcon = BitmapDescriptor.defaultMarkerWithHue(coachHue);
            newMarkers.add(Marker(
              markerId: MarkerId('${station.id}:coach:${entries[i].key}'),
              position: coachPos,
              infoWindow: InfoWindow(title: '${station.name} - ${entries[i].key}', snippet: coachLevel.label),
              icon: coachIcon,
              alpha: 0.0,
              anchor: const Offset(0.5, 0.5),
            ));
          }
        }
      }
    }

    // Fade in new markers
    _state = MarkerUpdate(newMarkers, 0.0);
    for (var i = 1; i <= 10; i++) {
      final alpha = i / 10.0;
      await Future.delayed(const Duration(milliseconds: 50));
      _state = MarkerUpdate(newMarkers.map((m) => m.copyWith(alphaParam: alpha)).toSet(), alpha);
    }

    return _state;
  }
}

/// Provider for managing map markers with smooth transitions and icon caching
final mapMarkerProvider = Provider.autoDispose((ref) => MapMarkerStateManager());