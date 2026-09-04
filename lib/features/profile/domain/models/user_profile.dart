import 'package:navigator/features/profile/domain/models/badge_item.dart';

class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String avatarInitials;
  final int safetyScore; // 0-100
  final String tierTitle; // "Safe Driver Master", "Elite Navigator"
  final double totalDistanceKm;
  final int speedingEventsCount;
  final int cleanTripsCount;
  final int karmaPoints;
  final int rankPosition;
  final List<BadgeItem> badges;
  final DateTime joinedDate;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.safetyScore,
    required this.tierTitle,
    required this.totalDistanceKm,
    required this.speedingEventsCount,
    required this.cleanTripsCount,
    required this.karmaPoints,
    required this.rankPosition,
    required this.badges,
    required this.joinedDate,
  });

  int get driverLevel {
    if (karmaPoints >= 1500) return 5;
    if (karmaPoints >= 700) return 4;
    if (karmaPoints >= 300) return 3;
    if (karmaPoints >= 100) return 2;
    return 1;
  }

  bool get isLevel5 => driverLevel >= 5;

  String get driverLevelTitle {
    switch (driverLevel) {
      case 5:
        return 'Level 5 • Ishonchli Haydovchi (Darhol xaritada chiqadi)';
      case 4:
        return 'Level 4 • Yo\'l Ustasi (Road Master)';
      case 3:
        return 'Level 3 • Ishonchli Navigator (Trusted)';
      case 2:
        return 'Level 2 • Faol Haydovchi (Active)';
      default:
        return 'Level 1 • Yangi Haydovchi (Newbie)';
    }
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? avatarInitials,
    int? safetyScore,
    String? tierTitle,
    double? totalDistanceKm,
    int? speedingEventsCount,
    int? cleanTripsCount,
    int? karmaPoints,
    int? rankPosition,
    List<BadgeItem>? badges,
    DateTime? joinedDate,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      safetyScore: safetyScore ?? this.safetyScore,
      tierTitle: tierTitle ?? this.tierTitle,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      speedingEventsCount: speedingEventsCount ?? this.speedingEventsCount,
      cleanTripsCount: cleanTripsCount ?? this.cleanTripsCount,
      karmaPoints: karmaPoints ?? this.karmaPoints,
      rankPosition: rankPosition ?? this.rankPosition,
      badges: badges ?? this.badges,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  factory UserProfile.defaultUser() {
    return UserProfile(
      userId: 'usr_me',
      name: 'Haydovchi',
      email: 'driver@smartradar.io',
      avatarInitials: 'H',
      safetyScore: 100,
      tierTitle: 'Level 1 Yangi Haydovchi',
      totalDistanceKm: 0.0,
      speedingEventsCount: 0,
      cleanTripsCount: 0,
      karmaPoints: 0,
      rankPosition: 1,
      badges: const [],
      joinedDate: DateTime.now(),
    );
  }
}
