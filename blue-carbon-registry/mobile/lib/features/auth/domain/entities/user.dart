enum UserRole {
  ngo,
  admin,
  buyer,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.ngo:
        return 'NGO';
      case UserRole.admin:
        return 'Admin';
      case UserRole.buyer:
        return 'Buyer';
    }
  }

  String get route {
    switch (this) {
      case UserRole.ngo:
        return '/ngo';
      case UserRole.admin:
        return '/admin';
      case UserRole.buyer:
        return '/buyer';
    }
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? organizationName;
  final String? phone;
  final String locale;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.organizationName,
    this.phone,
    this.locale = 'en',
    required this.createdAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? organizationName,
    String? phone,
    String? locale,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      organizationName: organizationName ?? this.organizationName,
      phone: phone ?? this.phone,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}