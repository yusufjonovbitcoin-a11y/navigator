import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/features/map_radar/presentation/widgets/speedometer_hud.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';
import 'package:navigator/features/navigation/presentation/widgets/route_card.dart';

void main() {
  testWidgets('SpeedometerHud renders speed and limit correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpeedometerHud(
            currentSpeedKmh: 68.0,
            speedLimitKmh: 70,
            isWarningActive: false,
          ),
        ),
      ),
    );

    expect(find.text('68'), findsOneWidget);
    expect(find.text('KM/H'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
  });

  testWidgets('RouteCard renders route details and badge correctly', (WidgetTester tester) async {
    final route = RouteInfo(
      id: 'test-1',
      name: 'Bunyodkor Expressway',
      points: const [LatLng(41.31, 69.24)],
      distanceKm: 8.5,
      durationMinutes: 14,
      radarCount: 3,
      riskScore: 65,
      isSafest: false,
      summary: 'Heavy traffic near central plaza',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteCard(
            route: route,
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Bunyodkor Expressway'), findsOneWidget);
    expect(find.text('14 min'), findsOneWidget);
    expect(find.text('8.5 km'), findsOneWidget);
    expect(find.text('3 radars'), findsOneWidget);
    expect(find.text('Fastest Route'), findsOneWidget);
  });
}
