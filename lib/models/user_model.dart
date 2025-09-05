// lib/models/user_model.dart
class User {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;

  User({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
    );
  }
}