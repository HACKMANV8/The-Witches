import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:metropulse/state/map_marker_state.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  MarkerUpdate _lastMarkerUpdate = MarkerUpdate(const <Marker>{}, 1.0);
  bool _isUpdating = false;
  bool _showCoach = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMarkers());
  }

  Future<void> _updateMarkers() async {
    if (_isUpdating) return;
    _isUpdating = true;

    final stationsAsync = ref.read(stationsProvider);
    final liveCrowd = ref.read(aggregatedCrowdByStationProvider);
    final coachLevels = ref.read(aggregatedCrowdByStationCoachProvider);

    await stationsAsync.when(
        data: (stations) async {
        final manager = ref.read(mapMarkerProvider);
        // compute nearest station to current location to highlight it
        final posAsync = ref.read(currentLocationProvider);
        final pos = posAsync.maybeWhen(data: (p) => p, orElse: () => null);
        String? highlightedStationId;
        if (pos != null) {
          var minDist = double.infinity;
          for (final s in stations) {
            if (s.latitude == null || s.longitude == null) continue;
            final dLat = s.latitude! - pos.latitude;
            final dLng = s.longitude! - pos.longitude;
            final dist = dLat * dLat + dLng * dLng;
            if (dist < minDist) {
              minDist = dist;
              highlightedStationId = s.id;
            }
          }
        }

        final update = await manager.updateMarkers(
          stations,
          liveCrowd,
          coachLevels: coachLevels,
          showCoach: _showCoach,
          highlightedStationId: highlightedStationId,
        );
        if (mounted) {
          setState(() => _lastMarkerUpdate = update);
        }
      },
      error: (_, __) {}, // Handle error appropriately
      loading: () {},
    );

    _isUpdating = false;
  }

  @override
  Widget build(BuildContext context) {
    // Register listeners inside build; Riverpod requires `ref.listen` to be used
    // from widget build methods (ConsumerWidget / ConsumerState.build). Placing
    // the listeners here avoids the runtime assertion seen when calling
    // `ref.listen` in initState on some Riverpod versions.
    ref.listen(stationCrowdStreamProvider, (_, __) => _updateMarkers());
    // Also listen for local optimistic overrides so markers update immediately when user reports.
    ref.listen(localCrowdOverridesProvider, (_, __) => _updateMarkers());
    // Marker updates are registered in initState; build stays pure.

    // Fallback camera to Bengaluru
    const fallbackCenter = LatLng(12.9716, 77.5946);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Crowd Map"),
        actions: [
          IconButton(
            tooltip: 'Toggle coach-level markers',
            icon: Icon(_showCoach ? Icons.train : Icons.directions_railway),
            onPressed: () {
              setState(() => _showCoach = !_showCoach);
              _updateMarkers();
            },
          ),
          if (kDebugMode)
            IconButton(
              tooltip: 'Seed sample coach overrides (debug)',
              icon: const Icon(Icons.bug_report),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await seedSampleCoachOverrides(count: 8);
                if (!mounted) return;
                messenger.showSnackBar(const SnackBar(content: Text('Seeded sample coach overrides')));
                _updateMarkers();
              },
            ),
          const ReportCrowdButton(),
        ],
      ),
      body: GoogleMap(
        markers: _lastMarkerUpdate.markers,
        initialCameraPosition: CameraPosition(
          target: ref.watch(currentLocationProvider).maybeWhen(
                data: (pos) => pos != null 
                    ? LatLng(pos.latitude, pos.longitude) 
                    : fallbackCenter,
                orElse: () => fallbackCenter,
              ),
          zoom: 13,
        ),
      ),
    );
  }
}
