class ApiEndpoints {
  // Default Mock Base URL - Can be switched dynamically via AppSettings
  static const String defaultBaseUrl = 'https://api.smartradar.io/v1';

  // Radars & Cameras
  static const String getRadars = '/radars';
  static const String getRadarsInBounds = '/radars/bounds';
  static const String getRadarDetails = '/radars/{id}';

  // Navigation & Routes
  static const String planRoute = '/routes/plan';
  static const String getRouteRiskZones = '/routes/{id}/risk-zones';
  static const String reportRouteHazard = '/routes/{id}/hazard';

  // AI Agent
  static const String aiChat = '/ai/chat';
  static const String aiDrivingInsights = '/ai/insights/weekly';
  static const String aiPredictRiskZones = '/ai/predict/risk-zones';

  // Reports
  static const String submitReport = '/reports';
  static const String getReportsNear = '/reports/nearby';
  static const String getUserReports = '/reports/user/{userId}';
  static const String upvoteReport = '/reports/{id}/upvote';

  // Profile & Gamification
  static const String getUserProfile = '/profile/{userId}';
  static const String getLeaderboard = '/leaderboard';
  static const String getBadges = '/profile/{userId}/badges';
}
