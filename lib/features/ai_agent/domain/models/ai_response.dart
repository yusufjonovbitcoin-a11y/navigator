enum AiCardType {
  none,
  weeklySummary,
  riskForecast,
  routeAdvice,
  radarHotspots,
}

class AiResponse {
  final String text;
  final List<String> suggestions;
  final Map<String, dynamic>? data;
  final AiCardType cardType;
  final DateTime timestamp;
  final bool isUser;

  const AiResponse({
    required this.text,
    this.suggestions = const [],
    this.data,
    this.cardType = AiCardType.none,
    required this.timestamp,
    this.isUser = false,
  });

  factory AiResponse.userMessage(String text) {
    return AiResponse(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      text: json['text'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      data: json['data'] as Map<String, dynamic>?,
      cardType: AiCardType.values.firstWhere(
        (c) => c.name == json['cardType'],
        orElse: () => AiCardType.none,
      ),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isUser: json['isUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'suggestions': suggestions,
      'data': data,
      'cardType': cardType.name,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
    };
  }
}
