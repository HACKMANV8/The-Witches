enum AlertSeverity { info, warning, critical }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final String? affectedStationId;
  final String? affectedLineColor;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.affectedStationId,
    this.affectedLineColor,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        severity: AlertSeverity.values.firstWhere((e) => e.name == json['severity']),
        affectedStationId: json['affected_station_id'] as String?,
        affectedLineColor: json['affected_line_color'] as String?,
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'severity': severity.name,
        'affected_station_id': affectedStationId,
        'affected_line_color': affectedLineColor,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    AlertSeverity? severity,
    String? affectedStationId,
    String? affectedLineColor,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AlertModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        severity: severity ?? this.severity,
        affectedStationId: affectedStationId ?? this.affectedStationId,
        affectedLineColor: affectedLineColor ?? this.affectedLineColor,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
