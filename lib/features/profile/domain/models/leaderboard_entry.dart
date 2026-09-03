class LeaderboardEntry {
  final int rank;
  final String userId;
  final String userName;
  final String avatarInitials;
  final int safetyScore;
  final int karmaPoints;
  final double distanceKm;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.avatarInitials,
    required this.safetyScore,
    required this.karmaPoints,
    required this.distanceKm,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 1,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Driver',
      avatarInitials: json['avatarInitials'] as String? ?? 'D',
      safetyScore: json['safetyScore'] as int? ?? 90,
      karmaPoints: json['karmaPoints'] as int? ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'userName': userName,
      'avatarInitials': avatarInitials,
      'safetyScore': safetyScore,
      'karmaPoints': karmaPoints,
      'distanceKm': distanceKm,
      'isCurrentUser': isCurrentUser,
    };
  }
}
