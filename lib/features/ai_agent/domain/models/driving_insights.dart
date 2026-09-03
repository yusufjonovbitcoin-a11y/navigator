class DrivingInsights {
  final int weeklySpeedEvents;
  final int safetyScore; // 0 - 100
  final double distanceDrivenKm;
  final int cleanTripStreak;
  final int karmaPointsEarned;
  final List<String> badges;
  final List<String> aiSuggestions;
  final DateTime generatedAt;

  const DrivingInsights({
    required this.weeklySpeedEvents,
    required this.safetyScore,
    required this.distanceDrivenKm,
    required this.cleanTripStreak,
    required this.karmaPointsEarned,
    required this.badges,
    required this.aiSuggestions,
    required this.generatedAt,
  });

  factory DrivingInsights.fromJson(Map<String, dynamic> json) {
    return DrivingInsights(
      weeklySpeedEvents: json['weeklySpeedEvents'] as int? ?? 0,
      safetyScore: json['safetyScore'] as int? ?? 90,
      distanceDrivenKm: (json['distanceDrivenKm'] as num?)?.toDouble() ?? 142.5,
      cleanTripStreak: json['cleanTripStreak'] as int? ?? 6,
      karmaPointsEarned: json['karmaPointsEarned'] as int? ?? 120,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      aiSuggestions: (json['aiSuggestions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklySpeedEvents': weeklySpeedEvents,
      'safetyScore': safetyScore,
      'distanceDrivenKm': distanceDrivenKm,
      'cleanTripStreak': cleanTripStreak,
      'karmaPointsEarned': karmaPointsEarned,
      'badges': badges,
      'aiSuggestions': aiSuggestions,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
