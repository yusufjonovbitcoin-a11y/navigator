import 'package:flutter/material.dart';
import 'package:navigator/core/services/supabase_service.dart';
import 'package:navigator/features/profile/domain/models/badge_item.dart';
import 'package:navigator/features/profile/domain/models/leaderboard_entry.dart';
import 'package:navigator/features/profile/domain/models/user_profile.dart';
import 'package:navigator/features/profile/domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      final userId = user?.id ?? 'usr_me';

      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final badges = await getBadges();
        return UserProfile(
          userId: response['id'] as String? ?? userId,
          name: response['name'] as String? ?? 'Haydovchi',
          email: response['email'] as String? ?? (user?.email ?? 'driver@smartradar.io'),
          avatarInitials: response['avatar_initials'] as String? ?? 'H',
          safetyScore: (response['safety_score'] as num?)?.toInt() ?? 100,
          tierTitle: response['tier_title'] as String? ?? 'Level 1 Yangi Haydovchi',
          totalDistanceKm: (response['total_distance_km'] as num?)?.toDouble() ?? 0.0,
          speedingEventsCount: (response['speeding_count'] as num?)?.toInt() ?? 0,
          cleanTripsCount: (response['clean_trips'] as num?)?.toInt() ?? 0,
          karmaPoints: (response['karma_points'] as num?)?.toInt() ?? 0,
          rankPosition: (response['rank_position'] as num?)?.toInt() ?? 1,
          badges: badges,
          joinedDate: response['created_at'] != null
              ? DateTime.parse(response['created_at'] as String)
              : DateTime.now(),
        );
      }
    } catch (_) {}

    return UserProfile.defaultUser();
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await SupabaseService.client
          .from('leaderboard')
          .select()
          .order('rank', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        return data
            .map((j) => LeaderboardEntry.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    try {
      final profilesRes = await SupabaseService.client
          .from('profiles')
          .select()
          .order('karma_points', ascending: false)
          .limit(100);

      final List<dynamic> pData = profilesRes as List<dynamic>;
      if (pData.isNotEmpty) {
        final currentUserId = SupabaseService.client.auth.currentUser?.id;
        return pData.asMap().entries.map((entry) {
          final idx = entry.key;
          final p = entry.value as Map<String, dynamic>;
          final uId = p['id']?.toString() ?? 'usr_$idx';
          return LeaderboardEntry(
            rank: idx + 1,
            userId: uId,
            userName: p['name']?.toString() ?? 'Haydovchi ${idx + 1}',
            avatarInitials: p['avatar_initials']?.toString() ?? 'H',
            safetyScore: (p['safety_score'] as num?)?.toInt() ?? 100,
            karmaPoints: (p['karma_points'] as num?)?.toInt() ?? 0,
            distanceKm: (p['total_distance_km'] as num?)?.toDouble() ?? 0.0,
            isCurrentUser: uId == currentUserId,
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<List<BadgeItem>> getBadges() async {
    try {
      final response = await SupabaseService.client
          .from('badges')
          .select()
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        return data.map((json) {
          return BadgeItem(
            id: json['id'] as String? ?? 'b-0',
            title: json['title'] as String? ?? 'Badge',
            description: json['description'] as String? ?? '',
            icon: Icons.verified_user_rounded,
            color: const Color(0xFF007AFF),
            isUnlocked: json['is_unlocked'] as bool? ?? true,
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }
}
