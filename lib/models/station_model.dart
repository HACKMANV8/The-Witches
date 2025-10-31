class StationModel {
  final String id; // UUID
  final String stationCode;
  final String name;
  final String? line;
  final double? latitude;
  final double? longitude;

  const StationModel({
    required this.id,
    required this.stationCode,
    required this.name,
    this.line,
    this.latitude,
    this.longitude,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) => StationModel(
        id: json['id'] as String,
        stationCode: json['station_code'] as String,
        name: json['name'] as String,
        line: json['line'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'station_code': stationCode,
        'name': name,
        'line': line,
        'latitude': latitude,
        'longitude': longitude,
      };

  StationModel copyWith({
    String? id,
    String? stationCode,
    String? name,
    String? line,
    double? latitude,
    double? longitude,
  }) =>
      StationModel(
        id: id ?? this.id,
        stationCode: stationCode ?? this.stationCode,
        name: name ?? this.name,
        line: line ?? this.line,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}
