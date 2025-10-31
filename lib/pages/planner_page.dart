import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/services/route_service.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/widgets/route_card.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';
import 'package:metropulse/pages/route_detail_page.dart';

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
                            onView: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RouteDetailPage()),
                            ),
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

