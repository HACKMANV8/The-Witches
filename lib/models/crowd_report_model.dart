import 'package:metropulse/widgets/crowd_badge.dart';

class CrowdReportModel {
  final String id;
  final String stationId;
  final String? userId;
  final CrowdLevel crowdLevel;
  final DateTime timestamp;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CrowdReportModel({
    required this.id,
    required this.stationId,
    this.userId,
    required this.crowdLevel,
    required this.timestamp,
    this.isAnonymous = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CrowdReportModel.fromJson(Map<String, dynamic> json) => CrowdReportModel(
        id: json['id'] as String,
        stationId: json['station_id'] as String,
        userId: json['user_id'] as String?,
        crowdLevel: CrowdLevel.values.firstWhere((e) => e.name == json['crowd_level']),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'station_id': stationId,
        'user_id': userId,
        'crowd_level': crowdLevel.name,
        'timestamp': timestamp.toIso8601String(),
        'is_anonymous': isAnonymous,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  CrowdReportModel copyWith({
    String? id,
    String? stationId,
    String? userId,
    CrowdLevel? crowdLevel,
    DateTime? timestamp,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CrowdReportModel(
        id: id ?? this.id,
        stationId: stationId ?? this.stationId,
        userId: userId ?? this.userId,
        crowdLevel: crowdLevel ?? this.crowdLevel,
        timestamp: timestamp ?? this.timestamp,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
