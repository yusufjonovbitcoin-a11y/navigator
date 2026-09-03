import 'package:navigator/core/services/supabase_service.dart';
import 'package:navigator/features/reports/data/mock_report_repository.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/domain/repositories/report_repository.dart';

class SupabaseReportRepository implements ReportRepository {
  final MockReportRepository _fallback = MockReportRepository();

  @override
  Future<List<UserReport>> getRecentReports() async {
    try {
      final response = await SupabaseService.client
          .from('user_reports')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return await _fallback.getRecentReports();
      }

      return data
          .map((json) => UserReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getRecentReports();
    }
  }

  @override
  Future<List<UserReport>> getMyReports(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('user_reports')
          .select()
          .eq('author_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => UserReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getMyReports(userId);
    }
  }

  @override
  Future<UserReport> submitReport(UserReport report) async {
    try {
      final id = report.id.isEmpty
          ? 'rep_${DateTime.now().millisecondsSinceEpoch}'
          : report.id;
      final readyReport = report.copyWith(id: id);

      await SupabaseService.client
          .from('user_reports')
          .insert(readyReport.toSupabase());

      return readyReport;
    } catch (_) {
      return await _fallback.submitReport(report);
    }
  }

  @override
  Future<bool> upvoteReport(String reportId) async {
    try {
      final response = await SupabaseService.client
          .from('user_reports')
          .select('upvotes')
          .eq('id', reportId)
          .single();
      final current = (response['upvotes'] as int?) ?? 0;

      await SupabaseService.client
          .from('user_reports')
          .update({'upvotes': current + 1})
          .eq('id', reportId);
      return true;
    } catch (_) {
      return await _fallback.upvoteReport(reportId);
    }
  }

  @override
  Future<bool> downvoteReport(String reportId) async {
    try {
      final response = await SupabaseService.client
          .from('user_reports')
          .select('downvotes')
          .eq('id', reportId)
          .single();
      final current = (response['downvotes'] as int?) ?? 0;

      await SupabaseService.client
          .from('user_reports')
          .update({'downvotes': current + 1})
          .eq('id', reportId);
      return true;
    } catch (_) {
      return await _fallback.downvoteReport(reportId);
    }
  }

  @override
  Future<void> pruneExpiredReports() async {
    // Handled by database or backend
  }
}
