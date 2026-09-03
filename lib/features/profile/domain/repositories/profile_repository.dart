import 'package:navigator/features/profile/domain/models/badge_item.dart';
import 'package:navigator/features/profile/domain/models/leaderboard_entry.dart';
import 'package:navigator/features/profile/domain/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<List<LeaderboardEntry>> getLeaderboard();
  Future<List<BadgeItem>> getBadges();
}
