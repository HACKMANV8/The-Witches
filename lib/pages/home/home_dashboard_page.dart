import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:metropulse/theme.dart';
import 'package:metropulse/widgets/crowd_badge.dart';
import 'package:metropulse/pages/shell/home_shell.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/widgets/crowd_badge.dart' as badge;

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dateText = DateFormat('EEE, MMM d • h:mm a').format(now);
    final stationsAsync = ref.watch(stationsProvider);
    final crowdByStation = ref.watch(aggregatedCrowdByStationProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning,', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Metro Commuter', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  Row(
                    children: const [
                      ReportCrowdButton(),
                      SizedBox(width: 6),
                      Text('🚇', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Where do you want to go?',
                  prefixIcon: Icon(Icons.search),
                ),
                onTap: () {
                  // Navigate to planner tab when user taps the search field
                  HomeShell.maybeOf(context)?.setTab(2);
                },
                onSubmitted: (value) {
                  // If user submits a query, open Planner tab so they can choose destination
                  HomeShell.maybeOf(context)?.setTab(2);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      color: Colors.blue,
                      emoji: '🗺️',
                      title: 'View Map',
                      onTap: () {
                        // Switch to Map tab (index 1)
                        HomeShell.maybeOf(context)?.setTab(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      color: Colors.red,
                      emoji: '⚠️',
                      title: 'View Alerts',
                      onTap: () {
                        // Switch to Alerts tab (index 3)
                        HomeShell.maybeOf(context)?.setTab(3);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Crowd Nearby', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  stationsAsync.when(
                    data: (stations) {
                      // Pick first 3 stations and show their live level if available
                      final items = stations.take(3).map((s) {
                        final level = crowdByStation[s.id] ?? badge.CrowdLevel.moderate;
                        return _StationRow(station: s.name, lineColor: MPColors.purple, level: level);
                      }).toList();
                      return Column(
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            items[i],
                            if (i != items.length - 1) const SizedBox(height: 8),
                          ]
                        ],
                      );
                    },
                    loading: () => const Text('Loading stations...'),
                    error: (_, __) => const Text('Unable to load live crowd'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Open the Plan tab from the dashboard
                    HomeShell.maybeOf(context)?.setTab(2);
                  },
                  child: const Text('Plan Trip'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String title;
  final VoidCallback onTap;
  const _ActionCard({required this.color, required this.emoji, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  final String station;
  final Color lineColor;
  final CrowdLevel level;
  const _StationRow({required this.station, required this.lineColor, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(color: lineColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(station, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    double width = switch (level) {
                      CrowdLevel.low => constraints.maxWidth * 0.33,
                      CrowdLevel.moderate => constraints.maxWidth * 0.66,
                      CrowdLevel.high => constraints.maxWidth,
                    };
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: level.color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CrowdBadge(level: level),
          )
        ],
      ),
    );
  }
}
