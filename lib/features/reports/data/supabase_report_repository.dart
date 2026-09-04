import 'package:navigator/core/services/supabase_service.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/domain/repositories/report_repository.dart';

class SupabaseReportRepository implements ReportRepository {
  List<UserReport> _cachedReports = [];

  @override
  Future<List<UserReport>> getRecentReports() async {
    try {
      final response = await SupabaseService.client
          .from('user_reports')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      final List<dynamic> data = response as List<dynamic>;
      final reports = data
          .map((json) => UserReport.fromJson(json as Map<String, dynamic>))
          .toList();
      _cachedReports = reports;
      return reports;
    } catch (_) {
      return _cachedReports;
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
      return _cachedReports.where((r) => r.userId == userId).toList();
    }
  }

  @override
  Future<UserReport> submitReport(UserReport report) async {
    final id = report.id.isEmpty
        ? 'rep_${DateTime.now().millisecondsSinceEpoch}'
        : report.id;
    final readyReport = report.copyWith(id: id);

    try {
      await SupabaseService.client
          .from('user_reports')
          .upsert(readyReport.toSupabase());
      _cachedReports.removeWhere((r) => r.id == readyReport.id);
      _cachedReports.insert(0, readyReport);
      return readyReport;
    } catch (_) {
      _cachedReports.insert(0, readyReport);
      return readyReport;
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
      return false;
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
      return false;
    }
  }

  @override
  Future<void> pruneExpiredReports() async {
    // Handled directly by Supabase
  }
}
