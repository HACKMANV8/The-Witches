import 'package:metropulse/models/crowd_report_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class CrowdReportService {
  static Future<CrowdReportModel> submitReport(CrowdReportModel report) async {
    final data = await SupabaseService.insert('crowd_reports', report.toJson());
    return CrowdReportModel.fromJson(data.first);
  }

  static Future<List<CrowdReportModel>> getReportsByStation(String stationId, {int limit = 10}) async {
    final data = await SupabaseService.select(
      'crowd_reports',
      filters: {'station_id': stationId},
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );
    return data.map((json) => CrowdReportModel.fromJson(json)).toList();
  }

  static Future<List<CrowdReportModel>> getRecentReports({int limit = 20}) async {
    final data = await SupabaseService.select(
      'crowd_reports',
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );
    return data.map((json) => CrowdReportModel.fromJson(json)).toList();
  }

  static Future<List<CrowdReportModel>> getUserReports(String userId, {int limit = 10}) async {
    final data = await SupabaseService.select(
      'crowd_reports',
      filters: {'user_id': userId},
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );
    return data.map((json) => CrowdReportModel.fromJson(json)).toList();
  }
}
