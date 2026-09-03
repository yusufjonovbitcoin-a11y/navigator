import '../models/user_report.dart';

abstract class ReportRepository {
  Future<List<UserReport>> getRecentReports();
  Future<List<UserReport>> getMyReports(String userId);
  Future<UserReport> submitReport(UserReport report);
  Future<bool> upvoteReport(String reportId);
  Future<bool> downvoteReport(String reportId);
  Future<void> pruneExpiredReports();
}
