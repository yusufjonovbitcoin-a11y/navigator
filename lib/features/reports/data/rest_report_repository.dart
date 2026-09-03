import 'package:navigator/core/constants/api_endpoints.dart';
import 'package:navigator/core/network/api_client.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/domain/repositories/report_repository.dart';

class RestReportRepository implements ReportRepository {
  final ApiClient _apiClient;

  RestReportRepository(this._apiClient);

  @override
  Future<List<UserReport>> getRecentReports() async {
    final response = await _apiClient.get<List<UserReport>>(
      ApiEndpoints.getReportsNear,
      fromJson: (jsonList) {
        if (jsonList is List) {
          return jsonList
              .map((item) => UserReport.fromJson(item as Map<String, dynamic>))
              .where((r) => !r.isExpired)
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<List<UserReport>> getMyReports(String userId) async {
    final endpoint = ApiEndpoints.getUserReports.replaceAll('{userId}', userId);
    final response = await _apiClient.get<List<UserReport>>(
      endpoint,
      fromJson: (jsonList) {
        if (jsonList is List) {
          return jsonList
              .map((item) => UserReport.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Future<UserReport> submitReport(UserReport report) async {
    final response = await _apiClient.post<UserReport>(
      ApiEndpoints.submitReport,
      data: report.toJson(),
      fromJson: (json) => UserReport.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Failed to submit report');
  }

  @override
  Future<bool> upvoteReport(String reportId) async {
    final endpoint = ApiEndpoints.upvoteReport.replaceAll('{id}', reportId);
    final response = await _apiClient.post(endpoint);
    return response.success;
  }

  @override
  Future<bool> downvoteReport(String reportId) async {
    final endpoint = '${ApiEndpoints.getReportsNear}/$reportId/downvote';
    final response = await _apiClient.post(endpoint);
    return response.success;
  }

  @override
  Future<void> pruneExpiredReports() async {
    // REST backend handles expired reports automatically
  }
}
