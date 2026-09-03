import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/domain/repositories/report_repository.dart';
import 'package:uuid/uuid.dart';

class MockReportRepository implements ReportRepository {
  final List<UserReport> _reports = [
    // GAI / YPX Posts across Tashkent City
    UserReport(
      id: 'rep-01',
      type: ReportType.policePatrol,
      lat: 41.303200,
      lng: 69.231500,
      timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      userId: 'user_1',
      address: 'Bunyodkor shoh ko\'chasi (Magic City ro\'parasida)',
      note: 'YPX patruli o\'ng tomonda to\'xtatmoqda',
      upvotes: 18,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),
    UserReport(
      id: 'rep-gai-02',
      type: ReportType.policePatrol,
      lat: 41.321500,
      lng: 69.282000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      userId: 'user_2',
      address: 'Amir Temur ko\'chasi (Oloy bozori yonida)',
      note: 'GAI / YPX statsionar posti faol',
      upvotes: 24,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),
    UserReport(
      id: 'rep-gai-03',
      type: ReportType.policePatrol,
      lat: 41.278000,
      lng: 69.205000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      userId: 'user_3',
      address: 'Chilonzor Guliston chorrahasi',
      note: 'YPX patruli reyd o\'tkazmoqda',
      upvotes: 31,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),
    UserReport(
      id: 'rep-gai-04',
      type: ReportType.policePatrol,
      lat: 41.352000,
      lng: 69.288000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      userId: 'user_4',
      address: 'Yunusobod 11-mavze (Mega Planet yaqinida)',
      note: 'GAI xodimlari haydovchilarni tekshirmoqda',
      upvotes: 15,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),
    UserReport(
      id: 'rep-gai-05',
      type: ReportType.policePatrol,
      lat: 41.231000,
      lng: 69.215000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      userId: 'user_5',
      address: 'Yangi Sergeli ko\'chasi (Yarmarka chorrahasi)',
      note: 'YPX tezlik va tasma nazorati',
      upvotes: 19,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),
    UserReport(
      id: 'rep-gai-06',
      type: ReportType.policePatrol,
      lat: 41.344000,
      lng: 69.208000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      userId: 'user_6',
      address: 'Beruniy shoh ko\'chasi (Chig\'atoy yaqinida)',
      note: 'YPX patruli faol holatda',
      upvotes: 27,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),
    UserReport(
      id: 'rep-gai-07',
      type: ReportType.policePatrol,
      lat: 41.285000,
      lng: 69.345000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      userId: 'user_7',
      address: 'Rohat aylanmasi (GAI posti)',
      note: 'Shaharga kirish YPX nazorati',
      upvotes: 45,
      downvotes: 0,
      authorTrustLevel: 5,
      status: 'verified',
    ),

    // Other Hazards
    UserReport(
      id: 'rep-02',
      type: ReportType.accident,
      lat: 41.319000,
      lng: 69.255000,
      timestamp: DateTime.now().subtract(const Duration(minutes: 19)),
      userId: 'user_99',
      address: 'Mustaqillik Ave / Shahrisabz Crossroad',
      note: 'Minor fender bender blocking center lane',
      upvotes: 7,
      downvotes: 0,
      authorTrustLevel: 4,
      status: 'active',
    ),
    UserReport(
      id: 'rep-04',
      type: ReportType.roadwork,
      lat: 41.272000,
      lng: 69.245000,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      userId: 'user_45',
      address: 'Chilanzar 19th Quarter',
      note: 'Asphalt paving, slow down to 30 km/h',
      upvotes: 12,
      downvotes: 0,
      authorTrustLevel: 3,
      status: 'active',
    ),
  ];

  @override
  Future<List<UserReport>> getRecentReports() async {
    await Future.delayed(const Duration(milliseconds: 150));
    await pruneExpiredReports();
    return _reports.where((r) => !r.isExpired).toList();
  }

  @override
  Future<List<UserReport>> getMyReports(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _reports.where((r) => r.userId == userId).toList();
  }

  @override
  Future<UserReport> submitReport(UserReport report) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final newReport = report.copyWith(
      id: 'rep-${const Uuid().v4().substring(0, 8)}',
      timestamp: DateTime.now(),
      status: report.authorTrustLevel >= 5 ? 'verified' : 'active',
      upvotes: 1,
      downvotes: 0,
    );
    _reports.insert(0, newReport);
    return newReport;
  }

  @override
  Future<bool> upvoteReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      final r = _reports[idx];
      _reports[idx] = r.copyWith(
        upvotes: r.upvotes + 1,
        status: (r.upvotes + 1 >= 3) ? 'verified' : r.status,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> downvoteReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      final r = _reports[idx];
      final newDown = r.downvotes + 1;
      _reports[idx] = r.copyWith(downvotes: newDown);
      if (newDown >= 2 && newDown > r.upvotes) {
        _reports.removeAt(idx);
      }
      return true;
    }
    return false;
  }

  @override
  Future<void> pruneExpiredReports() async {
    _reports.removeWhere((r) => r.isExpired);
  }
}
