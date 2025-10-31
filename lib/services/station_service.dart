import 'package:metropulse/models/station_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class StationService {
  static Future<List<StationModel>> getAllStations() async {
    final data = await SupabaseService.select('stations', orderBy: 'name');
    return data.map((json) => StationModel.fromJson(json)).toList();
  }

  static Future<StationModel?> getStationById(String stationId) async {
    final data = await SupabaseService.selectSingle('stations', filters: {'id': stationId});
    return data != null ? StationModel.fromJson(data) : null;
  }

  static Future<List<StationModel>> getStationsByLine(String lineColor) async {
    final data = await SupabaseService.select('stations', filters: {'line': lineColor}, orderBy: 'name');
    return data.map((json) => StationModel.fromJson(json)).toList();
  }

  static Future<List<StationModel>> getNearbyStations({double? latitude, double? longitude, int limit = 5}) async {
    final data = await SupabaseService.select('stations', orderBy: 'name', limit: limit);
    return data.map((json) => StationModel.fromJson(json)).toList();
  }

  // Updating stations is not required for this MVP schema
}
