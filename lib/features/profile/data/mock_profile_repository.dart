import 'package:flutter/material.dart';
import 'package:navigator/features/profile/domain/models/badge_item.dart';
import 'package:navigator/features/profile/domain/models/leaderboard_entry.dart';
import 'package:navigator/features/profile/domain/models/user_profile.dart';
import 'package:navigator/features/profile/domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final badges = await getBadges();
    return UserProfile(
      userId: 'usr_me',
      name: 'Nurmukhammad R.',
      email: 'driver@smartradar.io',
      avatarInitials: 'NR',
      safetyScore: 94,
      tierTitle: 'Elite Safe Driver',
      totalDistanceKm: 1420.5,
      speedingEventsCount: 0,
      cleanTripsCount: 52,
      karmaPoints: 340,
      rankPosition: 4,
      badges: badges,
      joinedDate: DateTime.now().subtract(const Duration(days: 90)),
    );
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      LeaderboardEntry(
        rank: 1,
        userId: 'usr_1',
        userName: 'Rustam K.',
        avatarInitials: 'RK',
        safetyScore: 98,
        karmaPoints: 780,
        distanceKm: 3420.0,
      ),
      LeaderboardEntry(
        rank: 2,
        userId: 'usr_2',
        userName: 'Sardor A.',
        avatarInitials: 'SA',
        safetyScore: 96,
        karmaPoints: 620,
        distanceKm: 2890.5,
      ),
      LeaderboardEntry(
        rank: 3,
        userId: 'usr_3',
        userName: 'Dilshod T.',
        avatarInitials: 'DT',
        safetyScore: 95,
        karmaPoints: 490,
        distanceKm: 2140.0,
      ),
      LeaderboardEntry(
        rank: 4,
        userId: 'usr_me',
        userName: 'Nurmukhammad R.',
        avatarInitials: 'NR',
        safetyScore: 94,
        karmaPoints: 340,
        distanceKm: 1420.5,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        rank: 5,
        userId: 'usr_5',
        userName: 'Jasur M.',
        avatarInitials: 'JM',
        safetyScore: 91,
        karmaPoints: 280,
        distanceKm: 1180.0,
      ),
      LeaderboardEntry(
        rank: 6,
        userId: 'usr_6',
        userName: 'Bobur N.',
        avatarInitials: 'BN',
        safetyScore: 88,
        karmaPoints: 210,
        distanceKm: 980.0,
      ),
    ];
  }

  @override
  Future<List<BadgeItem>> getBadges() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      const BadgeItem(
        id: 'b-01',
        title: 'Safe Master',
        description: 'Maintain 90+ safety score across 30 trips',
        icon: Icons.verified_user_rounded,
        color: Color(0xFF00E5FF),
        isUnlocked: true,
      ),
      const BadgeItem(
        id: 'b-02',
        title: 'Zero Speeding Week',
        description: 'No radar alerts triggered for 7 straight days',
        icon: Icons.speed_rounded,
        color: Color(0xFF06D6A0),
        isUnlocked: true,
      ),
      const BadgeItem(
        id: 'b-03',
        title: 'Hazard Spotter',
        description: '5 road hazard reports verified by community',
        icon: Icons.shield_rounded,
        color: Color(0xFFFFB703),
        isUnlocked: true,
      ),
      const BadgeItem(
        id: 'b-04',
        title: 'Night Owl',
        description: '10 accident-free night trips after 22:00',
        icon: Icons.nightlight_round,
        color: Color(0xFFA855F7),
        isUnlocked: true,
      ),
      const BadgeItem(
        id: 'b-05',
        title: 'Tashkent Explorer',
        description: 'Drive over 1,000 kilometers in urban navigation',
        icon: Icons.explore_rounded,
        color: Color(0xFF3B82F6),
        isUnlocked: true,
      ),
      const BadgeItem(
        id: 'b-06',
        title: 'Eco Cruiser',
        description: 'Smooth braking and optimal fuel pace',
        icon: Icons.eco_rounded,
        color: Color(0xFF10B981),
        isUnlocked: false,
      ),
    ];
  }
}
