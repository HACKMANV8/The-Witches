// material import not needed here
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos;
import 'dart:ui' as ui;
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

  // Cache for large highlighted icons per crowd level
  final Map<CrowdLevel, BitmapDescriptor> _largeIconCache = {};

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

      // Choose icon: use larger custom icon for highlighted station
      final usedIcon = (highlightedStationId != null && highlightedStationId == station.id)
          ? await _largeIconForLevel(level)
          : icon;

      // Add the station-level marker
      // Decide zIndex to bring highlighted station to the front
      final z = (highlightedStationId != null && highlightedStationId == station.id) ? 2 : 1;
      newMarkers.add(Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude!, station.longitude!),
        infoWindow: InfoWindow(title: station.name, snippet: level.label),
        icon: usedIcon,
        alpha: 0.0, // Start invisible for fade-in
        zIndexInt: z,
      ));

      // If coach-level view is requested and we have coach data for this station,
      // render small offset markers (one per coach) colored by their coach-level.
      if (showCoach && coachLevels != null) {
        final coaches = coachLevels[station.id];
        if (coaches != null && coaches.isNotEmpty) {
          // arrange coaches linearly left/right of station (platform aligned)
          final entries = coaches.entries.toList();
          final count = entries.length;
          // spacing in meters between coach markers
          const spacingMeters = 10.0;
          for (var i = 0; i < count; i++) {
            // index offset from center: 0 -> center, 1 -> left, 2 -> right, 3 -> left2, etc.
            final idxFromCenter = (i.isEven) ? -(i ~/ 2) : ((i + 1) ~/ 2);
            final offsetMeters = idxFromCenter * spacingMeters;
            // convert meters to degrees roughly
            final dLat = 0.0;
            final dLng = (offsetMeters / (111320.0 * cos(station.latitude! * (3.141592653589793 / 180))));
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

  Future<BitmapDescriptor> _largeIconForLevel(CrowdLevel level) async {
    if (_largeIconCache.containsKey(level)) return _largeIconCache[level]!;
    // Create a simple circular bitmap with a colored fill for highlighted marker
    const size = 96;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final fillColor = (level == CrowdLevel.low)
        ? const ui.Color(0xFF4CAF50)
        : (level == CrowdLevel.moderate)
            ? const ui.Color(0xFFFFEB3B)
            : const ui.Color(0xFFF44336);
    final paint = ui.Paint()..style = ui.PaintingStyle.fill..color = fillColor;
    final center = ui.Offset(size / 2, size / 2);
    // outer circle
    canvas.drawCircle(center, size / 2.0, paint);
    // inner white circle
    final inner = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    canvas.drawCircle(center, size / 3.0, inner);
    // stroke ring for contrast
    final stroke = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      // withOpacity is deprecated; use withValues to preserve precision.
      ..color = const ui.Color(0xFF000000).withValues(alpha: 0.2)
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, size / 2.0 - 2.0, stroke);
    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final u8 = bytes!.buffer.asUint8List();
    // Use bytes() for google_maps_flutter >= 2.13.1
    final bd = BitmapDescriptor.bytes(u8);
    _largeIconCache[level] = bd;
    return bd;
  }
}

/// Provider for managing map markers with smooth transitions and icon caching
final mapMarkerProvider = Provider.autoDispose((ref) => MapMarkerStateManager());