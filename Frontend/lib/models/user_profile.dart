/// The signed-in user's profile (CLAUDE.md §6 `UserProfile`).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.exp = 0,
    this.level = 1,
    this.totalCompleted = 0,
  });

  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final int exp;
  final int level;
  final int totalCompleted;

  /// Builds a [UserProfile] from a `UserProfileDto` returned by
  /// `GET /api/auth/me` (`Backend/DTOs/Auth/UserProfileDto.cs`).
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: '${json['id']}',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      exp: json['exp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
    );
  }
}
