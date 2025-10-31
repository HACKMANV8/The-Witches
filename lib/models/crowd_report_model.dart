import 'package:metropulse/widgets/crowd_badge.dart';

class CrowdReportModel {
  final String? id;
  final String stationId; // station_code
  final String? userId; // uuid
  final int crowdLevelValue; // 1..5
  final String? coachPosition;
  final DateTime createdAt;

  const CrowdReportModel({
    this.id,
    required this.stationId,
    this.userId,
    required this.crowdLevelValue,
    this.coachPosition,
    required this.createdAt,
  });

  factory CrowdReportModel.fromJson(Map<String, dynamic> json) => CrowdReportModel(
        id: json['id'] as String?,
        stationId: json['station_id'] as String,
        userId: json['user_id'] as String?,
        crowdLevelValue: (json['crowd_level'] as num).toInt(),
        coachPosition: json['coach_position'] as String?,
        createdAt: DateTime.parse((json['created_at'] ?? json['timestamp']) as String),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'station_id': stationId,
        'user_id': userId,
        'crowd_level': crowdLevelValue,
        if (coachPosition != null) 'coach_position': coachPosition,
        'created_at': createdAt.toIso8601String(),
      };

  CrowdReportModel copyWith({
    String? id,
    String? stationId,
    String? userId,
    int? crowdLevelValue,
    String? coachPosition,
    DateTime? createdAt,
  }) =>
      CrowdReportModel(
        id: id ?? this.id,
        stationId: stationId ?? this.stationId,
        userId: userId ?? this.userId,
        crowdLevelValue: crowdLevelValue ?? this.crowdLevelValue,
        coachPosition: coachPosition ?? this.coachPosition,
        createdAt: createdAt ?? this.createdAt,
      );

  // Convenience: map 1..5 to UI levels
  static CrowdLevel toUiLevel(int level) {
    if (level <= 2) return CrowdLevel.low;
    if (level == 3) return CrowdLevel.moderate;
    return CrowdLevel.high;
  }
}
