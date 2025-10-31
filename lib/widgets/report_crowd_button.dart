import 'package:flutter/material.dart';
import 'package:metropulse/widgets/report_crowd_sheet.dart';

class ReportCrowdButton extends StatelessWidget {
  final Color? iconColor;
  const ReportCrowdButton({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Report crowd',
      icon: Icon(Icons.emoji_people, color: iconColor ?? Theme.of(context).colorScheme.primary),
      onPressed: () => showReportCrowdSheet(context),
    );
  }
}


