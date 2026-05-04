import 'dart:convert';

class UserProfile {
  final String name;
  final String avatarUrl;
  final DateTime joinedDate;
  final int level;

  UserProfile({
    required this.name,
    required this.avatarUrl,
    required this.joinedDate,
    this.level = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'joinedDate': joinedDate.toIso8601String(),
      'level': level,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      avatarUrl: map['avatarUrl'],
      joinedDate: DateTime.parse(map['joinedDate']),
      level: map['level'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
