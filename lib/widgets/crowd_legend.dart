import 'package:flutter/material.dart';
import 'package:metropulse/widgets/predicted_crowd_badge.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

class CrowdLegend extends StatelessWidget {
  const CrowdLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Legend: '),
        const SizedBox(width: 8),
        PredictedCrowdBadge(
          currentLevel: CrowdLevel.low,
          predictedLevel: CrowdLevel.moderate,
        ),
        const SizedBox(width: 4),
        Text(
          'Current/Predicted',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}