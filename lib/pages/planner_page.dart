import 'package:flutter/material.dart';
import 'package:metropulse/widgets/route_card.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';
import 'package:metropulse/pages/route_detail_page.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Trip Planner'),
        actions: const [ReportCrowdButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _FromToFields(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Find Best Routes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  RouteCard(
                    title: 'Least Crowded',
                    accentColor: Colors.green,
                    tip: '🟢 Board rear coach',
                    onView: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RouteDetailPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RouteCard(
                    title: 'Fastest',
                    accentColor: Colors.red,
                    tip: '🔴 Shortest time',
                    onView: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RouteDetailPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RouteCard(
                    title: 'Balanced',
                    accentColor: Colors.amber,
                    tip: '🟡 Good compromise',
                    onView: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RouteDetailPage()),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FromToFields extends StatelessWidget {
  const _FromToFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.place), hintText: 'From')),
        SizedBox(height: 8),
        TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.flag), hintText: 'To')),
      ],
    );
  }
}

// RouteCard extracted to lib/widgets/route_card.dart
