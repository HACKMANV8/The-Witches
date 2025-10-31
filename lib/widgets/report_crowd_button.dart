import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/app_state.dart';
import 'package:metropulse/widgets/report_crowd_sheet.dart';

class ReportCrowdButton extends ConsumerWidget {
  final Color? iconColor;
  const ReportCrowdButton({super.key, this.iconColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final canReport = session.isAuthenticated && !session.isGuest;
    return IconButton(
      tooltip: canReport ? 'Report crowd' : 'Sign in to report',
      icon: Icon(Icons.emoji_people, color: iconColor ?? Theme.of(context).colorScheme.primary),
      onPressed: canReport
          ? () => showReportCrowdSheet(context)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign in to submit crowd reports.')),
              );
            },
    );
  }
}


