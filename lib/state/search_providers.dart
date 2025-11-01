import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/services/station_service.dart';

// Simple state provider to hold the last search string entered on the Home page
final homeSearchQueryProvider = StateProvider<String?>((ref) => null);

// FutureProvider that computes the best-matching station id (by name) for the last query.
final homeSearchMatchProvider = FutureProvider<String?>((ref) async {
  final query = ref.watch(homeSearchQueryProvider);
  if (query == null) return null;
  final q = query.trim();
  if (q.isEmpty) return null;

  // Load stations and find best match: exact, startsWith, contains (case-insensitive)
  final stations = await StationService.getAllStations();
  final lower = q.toLowerCase();

  // Exact match
  for (final s in stations) {
    if (s.name.toLowerCase() == lower) return s.id;
  }
  // Starts with
  for (final s in stations) {
    if (s.name.toLowerCase().startsWith(lower)) return s.id;
  }
  // Contains
  for (final s in stations) {
    if (s.name.toLowerCase().contains(lower)) return s.id;
  }

  return null;
});