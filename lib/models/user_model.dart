class User {
  final String id;
  final String name;
  final String email;
  final Avatar? avatar;
  final String role;
  final double walletBalance;
  final Map<String, dynamic>? preferences;
  final String? language;
  final String? location;
  final bool notificationsEnabled;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    required this.walletBalance,
    this.preferences,
    this.language,
    this.location,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
      role: json['role'] ?? 'user',
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      preferences: json['preferences'],
      language: json['language'],
      location: json['location'],
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar?.toJson(),
      'role': role,
      'walletBalance': walletBalance,
      'preferences': preferences,
      'language': language,
      'location': location,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
}

class Avatar {
  final String publicId;
  final String url;

  Avatar({
    required this.publicId,
    required this.url,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}
