import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/widgets/crowd_badge.dart';
import 'package:state_notifier/state_notifier.dart';

// Global cache to avoid recreating BitmapDescriptor objects
final _markerIconCache = <CrowdLevel, BitmapDescriptor>{};

class MarkerUpdate {
  final Set<Marker> markers;
  final double alpha;

  MarkerUpdate(this.markers, this.alpha);
}

class MapMarkerState extends StateNotifier<MarkerUpdate> {
  MapMarkerState() : super(MarkerUpdate(<Marker>{}, 1.0));

  /// Update markers with a smooth transition based on new crowd levels.
  Future<void> updateMarkers(List<StationModel> stations, Map<String, CrowdLevel> crowdLevels) async {
    // First fade out existing markers
    for (var i = 10; i > 0; i--) {
      final alpha = i / 10.0;
      state = MarkerUpdate(state.markers, alpha);
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

      // Use cached icon or create and cache a new one
      if (!_markerIconCache.containsKey(level)) {
        _markerIconCache[level] = BitmapDescriptor.defaultMarkerWithHue(hue);
      }
      final icon = _markerIconCache[level]!;

      newMarkers.add(Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude!, station.longitude!),
        infoWindow: InfoWindow(title: station.name, snippet: level.label),
        icon: icon,
        alpha: 0.0, // Start invisible for fade-in
      ));
    }

    // Now fade in the new markers
    state = MarkerUpdate(newMarkers, 0.0);
    for (var i = 1; i <= 10; i++) {
      final alpha = i / 10.0;
      await Future.delayed(const Duration(milliseconds: 50));
      state = MarkerUpdate(newMarkers.map((m) => m.copyWith(alphaParam: alpha)).toSet(), alpha);
    }
  }
}

/// Provider for managing map markers with smooth transitions and icon caching.
final mapMarkerProvider = StateNotifierProvider<MapMarkerState, MarkerUpdate>((ref) {
  return MapMarkerState();
});