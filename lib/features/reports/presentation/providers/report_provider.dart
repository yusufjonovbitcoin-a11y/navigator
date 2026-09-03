import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/reports/data/supabase_report_repository.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/domain/repositories/report_repository.dart';

// User Karma State
final userKarmaProvider = StateProvider<int>((ref) => 1680); // Level 5 Road Marshal

// Report repository provider powered by Supabase (with offline fallback)
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return SupabaseReportRepository();
});

// Reports list state notifier
class ReportListNotifier extends StateNotifier<AsyncValue<List<UserReport>>> {
  final ReportRepository _repo;
  final Ref _ref;

  ReportListNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getRecentReports();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> submitReport({
    required ReportType type,
    required double lat,
    required double lng,
    String? address,
    String? note,
  }) async {
    try {
      final currentKarma = _ref.read(userKarmaProvider);
      final isLevel5 = currentKarma >= 1500;
      final trustLevel = isLevel5 ? 5 : (currentKarma >= 700 ? 4 : (currentKarma >= 300 ? 3 : 2));

      final report = UserReport(
        id: '',
        type: type,
        lat: lat,
        lng: lng,
        timestamp: DateTime.now(),
        userId: 'usr_me',
        address: address,
        note: note,
        authorTrustLevel: trustLevel,
        status: isLevel5 ? 'verified' : 'active',
      );

      await _repo.submitReport(report);

      // Reward Karma points (+15 for Level 5, +10 for standard)
      final karmaBonus = isLevel5 ? 15 : 10;
      _ref.read(userKarmaProvider.notifier).state += karmaBonus;

      await loadReports();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> upvote(String id) async {
    await _repo.upvoteReport(id);
    // Reward +5 Karma points for community validation
    _ref.read(userKarmaProvider.notifier).state += 5;
    await loadReports();
  }

  Future<void> downvote(String id) async {
    await _repo.downvoteReport(id);
    await loadReports();
  }
}

final reportListProvider =
    StateNotifierProvider<ReportListNotifier, AsyncValue<List<UserReport>>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return ReportListNotifier(repo, ref);
});
