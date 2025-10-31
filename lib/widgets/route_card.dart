import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final String tip;
  final VoidCallback? onView;
  const RouteCard({super.key, required this.title, required this.accentColor, required this.tip, this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 24, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text('Time estimate • Route path summary', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(tip),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(onPressed: onView, child: const Text('View Route')),
          ),
        ],
      ),
    );
  }
}
