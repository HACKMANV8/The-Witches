import 'package:metropulse/widgets/crowd_badge.dart';

class StationModel {
  final String id;
  final String name;
  final String code;
  final String lineColor;
  final double latitude;
  final double longitude;
  final CrowdLevel? currentCrowdLevel;
  final DateTime? lastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.lineColor,
    required this.latitude,
    required this.longitude,
    this.currentCrowdLevel,
    this.lastUpdated,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) => StationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        lineColor: json['line_color'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        currentCrowdLevel: json['current_crowd_level'] != null
            ? CrowdLevel.values.firstWhere((e) => e.name == json['current_crowd_level'])
            : null,
        lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated'] as String) : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'line_color': lineColor,
        'latitude': latitude,
        'longitude': longitude,
        'current_crowd_level': currentCrowdLevel?.name,
        'last_updated': lastUpdated?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  StationModel copyWith({
    String? id,
    String? name,
    String? code,
    String? lineColor,
    double? latitude,
    double? longitude,
    CrowdLevel? currentCrowdLevel,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      StationModel(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        lineColor: lineColor ?? this.lineColor,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        currentCrowdLevel: currentCrowdLevel ?? this.currentCrowdLevel,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
