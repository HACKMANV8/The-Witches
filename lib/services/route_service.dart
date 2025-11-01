import 'package:metropulse/models/route_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class RouteService {
  static Future<List<RouteModel>> findRoutes({
    required String fromStationId,
    required String toStationId,
  }) async {
    try {
      // Use the find_or_calculate_route function
      final response = await SupabaseConfig.client
          .rpc('find_or_calculate_route', params: {
        'from_code': fromStationId,
        'to_code': toStationId,
      });
      
      if (response == null) return [];
      
      if (response is List) {
        return response.map((json) => RouteModel.fromJson(json)).toList();
      } else {
        // Single route returned
        return [RouteModel.fromJson(response)];
      }
    } catch (e) {
      print('Error finding routes: $e');
      return [];
    }
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
