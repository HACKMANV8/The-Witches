import 'package:flutter/material.dart';
import 'package:metropulse/theme.dart';
import 'package:metropulse/widgets/report_crowd_button.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Crowd Map'),
        actions: const [ReportCrowdButton()],
      ),
      body: Stack(
        children: [
          // Placeholder map canvas
          Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Text('Map placeholder — connect Google Maps SDK later'),
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
