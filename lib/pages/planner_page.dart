import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/services/route_service.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/services/station_service.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metropulse/widgets/route_card.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';
import 'package:metropulse/pages/route_results_page.dart';

class PlannerPage extends ConsumerStatefulWidget {
  const PlannerPage({super.key});

  @override
  ConsumerState<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends ConsumerState<PlannerPage> {
  String? fromStationId;
  String? toStationId;
  bool loading = false;
  List<RouteModelWrapper> results = [];

  Future<void> _findRoutes() async {
    if (fromStationId == null || toStationId == null) return;
    setState(() => loading = true);
    try {
      final routes = await RouteService.findRoutes(fromStationId: fromStationId!, toStationId: toStationId!);
      setState(() {
        results = routes
            .map((r) => RouteModelWrapper(
                  title: 'Duration: ${r.durationMinutes} min • ₹${r.fare.toStringAsFixed(0)}',
                  tip: r.intermediateStationIds.isEmpty ? 'Direct' : '${r.intermediateStationIds.length} stops',
                  accent: Colors.black,
                ))
            .toList();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _useMyLocationAsFrom() async {
    final pos = await ref.read(currentLocationProvider.future);
    if (!mounted) return;
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not available or permission denied')));
      return;
    }
    // Find nearest station
    final stations = await StationService.getAllStations();
    StationModel? nearest;
    double best = double.infinity;
    for (final s in stations) {
      if (s.latitude == null || s.longitude == null) continue;
      final d = Geolocator.distanceBetween(pos.latitude, pos.longitude, s.latitude!, s.longitude!);
      if (d < best) {
        best = d;
        nearest = s;
      }
    }
    if (nearest != null) {
      if (!mounted) return;
      setState(() => fromStationId = nearest!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Using nearest station: ${nearest.name}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Trip Planner'),
        actions: const [ReportCrowdButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            stationsAsync.when(
              data: (stations) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: fromStationId,
                      items: stations
                          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(color: Colors.black))))
                          .toList(),
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.place), hintText: 'From'),
                      onChanged: (v) => setState(() => fromStationId = v),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _useMyLocationAsFrom,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Use my location'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Builder(builder: (context) {
                            final recAsync = ref.watch(recommendedStationsProvider(fromStationId ?? ''));
                            return recAsync.when(
                              data: (recs) {
                                if (recs.isEmpty) return const SizedBox.shrink();
                                return DropdownButtonFormField<String>(
                                  value: toStationId,
                                  items: recs.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (recommended)'))).toList(),
                                  decoration: const InputDecoration(prefixIcon: Icon(Icons.flag), hintText: 'Recommended alternatives'),
                                  onChanged: (v) => setState(() => toStationId = v),
                                );
                              },
                              loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: toStationId,
                      items: stations
                          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(color: Colors.black))))
                          .toList(),
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.flag), hintText: 'To'),
                      onChanged: (v) => setState(() => toStationId = v),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load stations', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : _findRoutes,
                    child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Find Best Routes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: results.isEmpty
                    ? [const Text('No routes yet', style: TextStyle(color: Colors.black))]
                    : [
                        for (final r in results) ...[
                          RouteCard(
                            title: r.title,
                            accentColor: r.accent,
                            tip: r.tip,
                            onView: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => RouteResultsPage(fromStationId: fromStationId!, toStationId: toStationId!))),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RouteModelWrapper {
  final String title;
  final String tip;
  final Color accent;
  RouteModelWrapper({required this.title, required this.tip, required this.accent});
}

