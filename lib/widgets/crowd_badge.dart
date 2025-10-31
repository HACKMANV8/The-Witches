import 'package:flutter/material.dart';
import 'package:metropulse/theme.dart';

enum CrowdLevel { low, moderate, high }

extension CrowdLevelExt on CrowdLevel {
  String get label => switch (this) {
        CrowdLevel.low => '🟢 Low',
        CrowdLevel.moderate => '🟡 Moderate',
        CrowdLevel.high => '🔴 High',
      };

  Color get color => switch (this) {
        CrowdLevel.low => MPColors.crowdLow,
        CrowdLevel.moderate => MPColors.crowdModerate,
        CrowdLevel.high => MPColors.crowdHigh,
      };
}

class CrowdBadge extends StatelessWidget {
  final CrowdLevel level;
  const CrowdBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final bg = level.color;
    final textColor = bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    // Use solid background with contrasting text for better readability.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.1,
        ),
      ),
    );
  }
}
