import 'package:metropulse/models/crowd_report_model.dart';
import 'package:metropulse/supabase/supabase_config.dart';

class CrowdReportService {
  static Future<CrowdReportModel> submitReport(CrowdReportModel report) async {
    // Let DB generate id/created_at; send numeric crowd_level and coach_position
    final insert = {
      'station_id': report.stationId,
      'user_id': report.userId,
      'crowd_level': report.crowdLevelValue,
      if (report.coachPosition != null) 'coach_position': report.coachPosition,
    };
    final data = await SupabaseService.insert('crowd_reports', insert);
    return CrowdReportModel.fromJson(data.first);
  }

  static Future<List<CrowdReportModel>> getReportsByStation(String stationId, {int limit = 10}) async {
    final data = await SupabaseService.select(
      'crowd_reports',
      filters: {'station_id': stationId},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
    return data.map((json) => CrowdReportModel.fromJson(json)).toList();
  }

  static Future<List<CrowdReportModel>> getRecentReports({int limit = 20}) async {
    final data = await SupabaseService.select(
      'crowd_reports',
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
    return data.map((json) => CrowdReportModel.fromJson(json)).toList();
  }

  static Future<List<CrowdReportModel>> getUserReports(String userId, {int limit = 10}) async {
    final data = await SupabaseService.select(
      'crowd_reports',
      filters: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
    return data.map((json) => CrowdReportModel.fromJson(json)).toList();
  }

  /// Stream recent crowd reports in realtime within a sliding time window.
  static Stream<List<CrowdReportModel>> streamRecentReports({Duration window = const Duration(minutes: 15)}) {
    return SupabaseService
        .from('crowd_reports')
        .stream(primaryKey: ['id'])
        .map((rows) {
          final cutoff = DateTime.now().subtract(window);
          final parsed = rows.map((json) => CrowdReportModel.fromJson(json)).toList();
          parsed.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return parsed.where((r) => r.createdAt.isAfter(cutoff)).toList();
        });
  }

  /// Stream reports for a specific station (useful for detail views)
  static Stream<List<CrowdReportModel>> streamStationReports(String stationId, {Duration window = const Duration(minutes: 15)}) {
    return SupabaseService
        .from('crowd_reports')
        .stream(primaryKey: ['id'])
        .map((rows) {
          final cutoff = DateTime.now().subtract(window);
          final parsed = rows.map((json) => CrowdReportModel.fromJson(json)).toList();
          parsed.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return parsed.where((r) => r.stationId == stationId && r.createdAt.isAfter(cutoff)).toList();
        });
  }
}
