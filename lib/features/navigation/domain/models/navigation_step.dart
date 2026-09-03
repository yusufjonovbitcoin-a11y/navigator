import 'package:flutter/material.dart';

enum ManeuverType {
  straight,
  turnLeft,
  turnRight,
  slightLeft,
  slightRight,
  uTurn,
  roundabout,
  arrive,
}

class NavigationStep {
  final String instruction;
  final double distanceMeters;
  final ManeuverType maneuver;
  final String streetName;

  const NavigationStep({
    required this.instruction,
    required this.distanceMeters,
    required this.maneuver,
    required this.streetName,
  });

  IconData get icon {
    switch (maneuver) {
      case ManeuverType.turnLeft:
        return Icons.turn_left;
      case ManeuverType.turnRight:
        return Icons.turn_right;
      case ManeuverType.slightLeft:
        return Icons.turn_slight_left;
      case ManeuverType.slightRight:
        return Icons.turn_slight_right;
      case ManeuverType.uTurn:
        return Icons.u_turn_left;
      case ManeuverType.roundabout:
        return Icons.roundabout_left;
      case ManeuverType.arrive:
        return Icons.flag;
      case ManeuverType.straight:
        return Icons.straight;
    }
  }

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      instruction: json['instruction'] as String? ?? 'Proceed',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 100.0,
      maneuver: ManeuverType.values.firstWhere(
        (m) => m.name == json['maneuver'],
        orElse: () => ManeuverType.straight,
      ),
      streetName: json['streetName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'distanceMeters': distanceMeters,
      'maneuver': maneuver.name,
      'streetName': streetName,
    };
  }
}
