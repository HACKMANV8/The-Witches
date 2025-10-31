import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

class RouteResultsPage extends ConsumerWidget {
  final String fromStationId;
  final String toStationId;
  const RouteResultsPage({required this.fromStationId, required this.toStationId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final crowds = ref.watch(aggregatedCrowdByStationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Route Results')),
      body: stationsAsync.when(
        data: (stations) {
          final byId = {for (final s in stations) s.id: s};
          final from = byId[fromStationId];
          final to = byId[toStationId];
          if (from == null || to == null) return const Center(child: Text('Invalid stations'));

          // Fastest (direct)
          final fastest = [from, to];

          // Least crowded: try recommended station near origin
          final recsAsync = ref.watch(recommendedStationsProvider(fromStationId));

          return recsAsync.when(
            data: (recs) {
              final leastCrowded = recs.isNotEmpty ? [from, recs.first, to] : fastest;
              final balanced = recs.length > 1 ? [from, recs[1], to] : leastCrowded;

              final options = [
                {'title': 'Fastest', 'stops': fastest},
                {'title': 'Least Crowded', 'stops': leastCrowded},
                {'title': 'Balanced', 'stops': balanced},
              ];

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final List<StationModel> stops = List<StationModel>.from(opt['stops'] as List<StationModel>);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(opt['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              Text('${stops.length - 1} stops • approx ${10 + (stops.length - 1) * 5} min', style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(height: 120, child: _SmallRouteMap(stops: stops)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: stops.map((s) {
                              final lvl = crowds[s.id];
                              return Chip(
                                avatar: CrowdBadge(level: lvl ?? CrowdLevel.low),
                                label: Text(s.name),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: options.length,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to compute recommendations')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load stations')),
      ),
    );
  }
}

class _SmallRouteMap extends StatelessWidget {
  final List<StationModel> stops;
  const _SmallRouteMap({required this.stops});

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty || stops.first.latitude == null || stops.first.longitude == null) {
      return const Center(child: Text('No map data'));
    }

    final center = LatLng(stops.first.latitude!, stops.first.longitude!);
    final markers = stops.where((s) => s.latitude != null && s.longitude != null).map((s) {
      return Marker(
        markerId: MarkerId(s.id),
        position: LatLng(s.latitude!, s.longitude!),
        infoWindow: InfoWindow(title: s.name),
      );
    }).toSet();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 13),
        markers: markers,
        liteModeEnabled: true,
        zoomControlsEnabled: false,
        myLocationEnabled: false,
      ),
    );
  }
}
