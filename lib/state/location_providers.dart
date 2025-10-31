import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/services/station_service.dart';

/// Provides the user's current station based on nearby stations.
/// This is a lightweight placeholder that queries nearby stations
/// and picks the first as the "current" station.
final currentStationProvider = FutureProvider<StationModel?>((ref) async {
  final stations = await StationService.getNearbyStations(limit: 1);
  return stations.isNotEmpty ? stations.first : null;
});


