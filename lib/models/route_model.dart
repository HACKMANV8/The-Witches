class RouteModel {
  final String id;
  final String fromStationId;
  final String toStationId;
  final int durationMinutes;
  final double fare;
  final List<String> intermediateStationIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RouteModel({
    required this.id,
    required this.fromStationId,
    required this.toStationId,
    required this.durationMinutes,
    required this.fare,
    required this.intermediateStationIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] as String,
        fromStationId: json['from_station_id'] as String,
        toStationId: json['to_station_id'] as String,
        durationMinutes: json['duration_minutes'] as int,
        fare: (json['fare'] as num).toDouble(),
        intermediateStationIds: (json['intermediate_station_ids'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'from_station_id': fromStationId,
        'to_station_id': toStationId,
        'duration_minutes': durationMinutes,
        'fare': fare,
        'intermediate_station_ids': intermediateStationIds,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  RouteModel copyWith({
    String? id,
    String? fromStationId,
    String? toStationId,
    int? durationMinutes,
    double? fare,
    List<String>? intermediateStationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RouteModel(
        id: id ?? this.id,
        fromStationId: fromStationId ?? this.fromStationId,
        toStationId: toStationId ?? this.toStationId,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        fare: fare ?? this.fare,
        intermediateStationIds: intermediateStationIds ?? this.intermediateStationIds,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
