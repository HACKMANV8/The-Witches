import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/state/live_crowd_providers.dart';
import 'package:metropulse/widgets/predicted_crowd_badge.dart';
import 'package:metropulse/widgets/crowd_badge.dart';

class PredictedStationsList extends ConsumerWidget {
  final List<StationModel> stations;
  final void Function(String stationId)? onStationTap;

  const PredictedStationsList({
    super.key,
    required this.stations,
    this.onStationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveCrowds = ref.watch(aggregatedCrowdByStationProvider);
    final predictedCrowds = ref.watch(predictedCrowdProvider).value ?? const <String, CrowdLevel>{};

    return ListView.builder(
      itemCount: stations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final station = stations[index];
        final currentLevel = liveCrowds[station.id] ?? CrowdLevel.moderate;
        final predictedLevel = predictedCrowds[station.id] ?? CrowdLevel.moderate;

        return ListTile(
          title: Text(station.name),
          trailing: PredictedCrowdBadge(
            currentLevel: currentLevel,
            predictedLevel: predictedLevel,
          ),
          onTap: onStationTap != null ? () => onStationTap!(station.id) : null,
        );
      },
    );
  }
}