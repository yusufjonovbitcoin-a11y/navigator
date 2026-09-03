import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/profile/data/mock_profile_repository.dart';
import 'package:navigator/features/profile/domain/models/badge_item.dart';
import 'package:navigator/features/profile/domain/models/leaderboard_entry.dart';
import 'package:navigator/features/profile/domain/models/user_profile.dart';
import 'package:navigator/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserProfile();
});

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getLeaderboard();
});

final badgesProvider = FutureProvider<List<BadgeItem>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getBadges();
});
