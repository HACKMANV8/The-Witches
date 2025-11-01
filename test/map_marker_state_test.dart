// Copyright 2023 MetroPulse. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metropulse/state/map_marker_state.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

void main() {
  group('MapMarkerStateManager', () {
    late MapMarkerStateManager manager;
    late StationModel testStation;

    setUp(() {
      manager = MapMarkerStateManager();
      testStation = StationModel(
        id: 'test1',
        name: 'Test Station 1',
        stationCode: 'TEST1',
        latitude: 1.0,
        longitude: 1.0,
      );
    });

    test('updateMarkers returns new markers with expected alpha progression', () async {
      final stations = [testStation];
      final crowdLevels = {'test1': CrowdLevel.moderate};
      
      // Initial state should have alpha 1.0
      expect(manager.current.alpha, equals(1.0));

      // Update markers and verify alpha progression
      final result = await manager.updateMarkers(stations, crowdLevels);
      
      // Final state should have alpha 1.0 and non-empty markers
      expect(result.alpha, equals(1.0));
      expect(result.markers, isNotEmpty);

      // Verify marker details
      final marker = result.markers.firstWhere((m) => m.markerId == const MarkerId('test1'));
      expect(marker.position.latitude, equals(1.0));
      expect(marker.position.longitude, equals(1.0));
      expect(marker.alpha, equals(1.0));
    });

    test('updateMarkers handles highlighted station correctly', () async {
      final stations = [testStation];
      final crowdLevels = {'test1': CrowdLevel.high};

      // Update with highlighted station
      final result = await manager.updateMarkers(
        stations,
        crowdLevels,
        highlightedStationId: 'test1',
      );

      // Verify highlighted marker has higher zIndex
      final marker = result.markers.firstWhere((m) => m.markerId == const MarkerId('test1'));
      expect(marker.zIndexInt, equals(2)); // Highlighted markers use zIndexInt 2
    });

    test('updateMarkers adds coach markers when showCoach is true', () async {
      final stations = [testStation];
      final crowdLevels = {'test1': CrowdLevel.moderate};
      final coachLevels = {
        'test1': {
          'coach1': CrowdLevel.low,
          'coach2': CrowdLevel.high,
        }
      };

      // Update with coach markers enabled
      final result = await manager.updateMarkers(
        stations,
        crowdLevels,
        coachLevels: coachLevels,
        showCoach: true,
      );

      // Should have main station marker + 2 coach markers
      expect(result.markers.length, equals(3));

      // Verify coach markers were created with correct IDs
      expect(
        result.markers.any((m) => m.markerId == const MarkerId('test1:coach:coach1')),
        isTrue,
      );
      expect(
        result.markers.any((m) => m.markerId == const MarkerId('test1:coach:coach2')),
        isTrue,
      );
    });
  });
}
