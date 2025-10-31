class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final bool notificationsEnabled;
  final bool anonymousReportingEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.notificationsEnabled = true,
    this.anonymousReportingEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
        anonymousReportingEnabled: json['anonymous_reporting_enabled'] as bool? ?? true,
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'notifications_enabled': notificationsEnabled,
        'anonymous_reporting_enabled': anonymousReportingEnabled,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    bool? notificationsEnabled,
    bool? anonymousReportingEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        anonymousReportingEnabled: anonymousReportingEnabled ?? this.anonymousReportingEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
