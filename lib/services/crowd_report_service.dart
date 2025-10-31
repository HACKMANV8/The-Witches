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

  /// Stream recent crowd reports in realtime within a sliding time window.
  static Stream<List<CrowdReportModel>> streamRecentReports({Duration window = const Duration(minutes: 15)}) {
    return SupabaseService
        .from('crowd_reports')
        .stream(primaryKey: ['id'])
        .map((rows) {
          final cutoff = DateTime.now().subtract(window);
          final parsed = rows.map((json) => CrowdReportModel.fromJson(json)).toList();
          parsed.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return parsed.where((r) => r.timestamp.isAfter(cutoff)).toList();
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
          parsed.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return parsed.where((r) => r.stationId == stationId && r.timestamp.isAfter(cutoff)).toList();
        });
  }
}
