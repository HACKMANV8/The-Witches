import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/widgets/crowd_badge.dart';
import 'package:metropulse/theme.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final liveCrowd = ref.watch(aggregatedCrowdByStationProvider);

    final markers = stationsAsync.maybeWhen(
      data: (stations) {
        // Skip stations without coordinates to avoid passing null to LatLng
        return stations
            .where((s) => s.latitude != null && s.longitude != null)
            .map((s) {
          final level = liveCrowd[s.id];
          final hue = switch (level) {
            CrowdLevel.low => BitmapDescriptor.hueGreen,
            CrowdLevel.moderate => BitmapDescriptor.hueYellow,
            CrowdLevel.high => BitmapDescriptor.hueRed,
            null => BitmapDescriptor.hueAzure,
          };

          final lat = s.latitude!;
          final lng = s.longitude!;

          return Marker(
            markerId: MarkerId(s.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: s.name, snippet: level?.label ?? 'No recent data'),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          );
        }).toSet();
      },
      orElse: () => <Marker>{},
    );

    // Fallback camera to Bengaluru
    const fallbackCenter = LatLng(12.9716, 77.5946);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Crowd Map'),
        actions: const [ReportCrowdButton()],
      ),
      body: Stack(
        children: [
          _SafeGoogleMap(
            initialCameraPosition: const CameraPosition(target: fallbackCenter, zoom: 11),
            markers: markers,
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: MPColors.green, label: 'Low'),
                  SizedBox(width: 12),
                  _LegendDot(color: MPColors.yellow, label: 'Moderate'),
                  SizedBox(width: 12),
                  _LegendDot(color: MPColors.red, label: 'High'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeGoogleMap extends StatelessWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  const _SafeGoogleMap({required this.initialCameraPosition, required this.markers});

  @override
  Widget build(BuildContext context) {
    try {
      return GoogleMap(
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: initialCameraPosition,
        markers: markers,
      );
    } catch (e) {
      return Center(
        child: Text(
          'Map unavailable. Please check your Maps API key and internet connection.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
