import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
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

    await stationsAsync.when(
      data: (stations) async {
        final manager = ref.read(mapMarkerProvider);
        final update = await manager.updateMarkers(stations, liveCrowd);
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
    // Watch for changes in live crowd data
    ref.listen(stationCrowdStreamProvider, (_, __) => _updateMarkers());

    // Fallback camera to Bengaluru
    const fallbackCenter = LatLng(12.9716, 77.5946);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Crowd Map"),
        actions: const [
          ReportCrowdButton(),
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
