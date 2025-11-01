import 'package:flutter/material.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

class PredictedCrowdBadge extends StatelessWidget {
  final CrowdLevel currentLevel;
  final CrowdLevel predictedLevel;

  const PredictedCrowdBadge({
    super.key,
    required this.currentLevel,
    required this.predictedLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main badge for current crowd level
        CrowdBadge(level: currentLevel),
        
        // Small dot for predicted level
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: predictedLevel.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}