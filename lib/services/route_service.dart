import 'package:metropulse/models/route_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class RouteService {
  static Future<List<RouteModel>> findRoutes({
    required String fromStationId,
    required String toStationId,
  }) async {
    final data = await SupabaseService.select(
      'routes',
      filters: {'from_station_id': fromStationId, 'to_station_id': toStationId},
      orderBy: 'duration_minutes',
    );
    return data.map((json) => RouteModel.fromJson(json)).toList();
  }

  static Future<RouteModel?> getRouteById(String routeId) async {
    final data = await SupabaseService.selectSingle('routes', filters: {'id': routeId});
    return data != null ? RouteModel.fromJson(data) : null;
  }

  static Future<List<RouteModel>> getAllRoutes() async {
    final data = await SupabaseService.select('routes', orderBy: 'duration_minutes');
    return data.map((json) => RouteModel.fromJson(json)).toList();
  }
}
