import 'package:flutter/material.dart';
import 'package:metropulse/theme.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stations = const [
      _StationStop('MG Road', StopType.start, CrowdLevel.moderate),
      _StationStop('Cubbon Park', StopType.transit, CrowdLevel.low),
      _StationStop('Majestic (Interchange)', StopType.transfer, CrowdLevel.high),
      _StationStop('Rajajinagar', StopType.transit, CrowdLevel.moderate),
      _StationStop('Yeshwanthpur', StopType.end, CrowdLevel.low),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Header with purple gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(gradient: MPDecorations.purpleHeaderGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const CrowdBadge(level: CrowdLevel.moderate),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('MG Road → Yeshwanthpur', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('28 min • 1 transfer • ₹32', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: stations.length,
              itemBuilder: (_, i) {
                final stop = stations[i];
                return _TimelineTile(
                  title: stop.name,
                  type: stop.type,
                  crowd: stop.crowd,
                  isFirst: i == 0,
                  isLast: i == stations.length - 1,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Text('🧭'),
                label: const Text('Start Navigation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum StopType { start, transit, transfer, end }

class _StationStop {
  final String name;
  final StopType type;
  final CrowdLevel crowd;
  const _StationStop(this.name, this.type, this.crowd);
}

class _TimelineTile extends StatelessWidget {
  final String title;
  final StopType type;
  final CrowdLevel crowd;
  final bool isFirst;
  final bool isLast;
  const _TimelineTile({required this.title, required this.type, required this.crowd, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      StopType.start => Icons.location_on,
      StopType.end => Icons.flag,
      StopType.transfer => Icons.sync_alt,
      StopType.transit => Icons.circle,
    };
    final iconColor = switch (type) {
      StopType.transfer => Colors.amber,
      _ => Theme.of(context).colorScheme.primary,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              alignment: Alignment.center,
              child: Icon(icon, size: type == StopType.transit ? 10 : 18, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: Colors.grey.withValues(alpha: 0.4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      switch (type) {
                        StopType.start => 'Board here',
                        StopType.transfer => 'Transfer • 4 min',
                        StopType.end => 'Exit here',
                        StopType.transit => 'Transit stop',
                      },
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                CrowdBadge(level: crowd),
              ],
            ),
          ),
        )
      ],
    );
  }
}


