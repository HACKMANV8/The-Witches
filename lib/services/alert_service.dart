import 'package:metropulse/models/alert_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class AlertService {
  static Future<List<AlertModel>> getActiveAlerts() async {
    final data = await SupabaseService.select(
      'alerts',
      filters: {'is_active': true},
      orderBy: 'start_time',
      ascending: false,
    );
    return data.map((json) => AlertModel.fromJson(json)).toList();
  }

  static Future<List<AlertModel>> getAlertsByStation(String stationId) async {
    final data = await SupabaseService.select(
      'alerts',
      filters: {'affected_station_id': stationId, 'is_active': true},
      orderBy: 'start_time',
      ascending: false,
    );
    return data.map((json) => AlertModel.fromJson(json)).toList();
  }

  static Future<List<AlertModel>> getAlertsByLine(String lineColor) async {
    final data = await SupabaseService.select(
      'alerts',
      filters: {'affected_line_color': lineColor, 'is_active': true},
      orderBy: 'start_time',
      ascending: false,
    );
    return data.map((json) => AlertModel.fromJson(json)).toList();
  }

  static Future<AlertModel?> getAlertById(String alertId) async {
    final data = await SupabaseService.selectSingle('alerts', filters: {'id': alertId});
    return data != null ? AlertModel.fromJson(data) : null;
  }
}
