import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/services/supabase_service.dart';
import 'package:navigator/features/map_radar/domain/models/parking_zone.dart';

class ParkingZoneState {
  final bool isDrawingMode;
  final List<LatLng> draftPoints;
  final List<ParkingZone> savedZones;
  final ParkingZone? selectedZone;

  const ParkingZoneState({
    this.isDrawingMode = false,
    this.draftPoints = const [],
    this.savedZones = const [],
    this.selectedZone,
  });

  ParkingZoneState copyWith({
    bool? isDrawingMode,
    List<LatLng>? draftPoints,
    List<ParkingZone>? savedZones,
    ParkingZone? selectedZone,
    bool clearSelectedZone = false,
  }) {
    return ParkingZoneState(
      isDrawingMode: isDrawingMode ?? this.isDrawingMode,
      draftPoints: draftPoints ?? this.draftPoints,
      savedZones: savedZones ?? this.savedZones,
      selectedZone: clearSelectedZone ? null : (selectedZone ?? this.selectedZone),
    );
  }
}

class ParkingZoneNotifier extends StateNotifier<ParkingZoneState> {
  ParkingZoneNotifier()
      : super(ParkingZoneState(
          savedZones: [
            // 0. Samarqand Registon Maydoni Parkovkasi
            ParkingZone(
              id: 'park_samarqand_registan_0',
              name: 'Registon Maydoni Parkovkasi',
              isPaid: false,
              priceInfo: 'Bepul',
              capacity: 120,
              availableSpots: 45,
              createdAt: DateTime.now().subtract(const Duration(hours: 3)),
              colorValue: 0xFF34C759,
              points: const [
                LatLng(39.654000, 66.974000),
                LatLng(39.655200, 66.974000),
                LatLng(39.655200, 66.975500),
                LatLng(39.654000, 66.975500),
              ],
            ),
            // 1. Tashkent City Mall Parking
            ParkingZone(
              id: 'park_tashkent_city_1',
              name: 'Tashkent City Mall Parkovkasi',
              isPaid: true,
              priceInfo: '5,000 so\'m/soat',
              capacity: 250,
              availableSpots: 64,
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              colorValue: 0xFF007AFF,
              points: const [
                LatLng(41.313200, 69.253000),
                LatLng(41.314500, 69.255500),
                LatLng(41.313000, 69.257000),
                LatLng(41.311800, 69.254500),
              ],
            ),
            // 2. Chilonzor Trade Mall Parking
            ParkingZone(
              id: 'park_chilonzor_2',
              name: 'Chilonzor Savdo Majmuasi Parkovkasi',
              isPaid: false,
              priceInfo: 'Bepul',
              capacity: 65,
              availableSpots: 22,
              createdAt: DateTime.now().subtract(const Duration(days: 5)),
              colorValue: 0xFF34C759,
              points: const [
                LatLng(41.284000, 69.206500),
                LatLng(41.285200, 69.208500),
                LatLng(41.284100, 69.209800),
                LatLng(41.283000, 69.207800),
              ],
            ),
            // 3. Magic City Parking
            ParkingZone(
              id: 'park_magic_city_3',
              name: 'Magic City Parkovkasi',
              isPaid: true,
              priceInfo: '10,000 so\'m/kun',
              capacity: 320,
              availableSpots: 95,
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
              colorValue: 0xFF007AFF,
              points: const [
                LatLng(41.302500, 69.232000),
                LatLng(41.304000, 69.234500),
                LatLng(41.302800, 69.236000),
                LatLng(41.301500, 69.233500),
              ],
            ),
            // 4. Minor Mosque Parking Area
            ParkingZone(
              id: 'park_minor_4',
              name: 'Minor Masjidi Parkovkasi',
              isPaid: false,
              priceInfo: 'Bepul',
              capacity: 110,
              availableSpots: 48,
              createdAt: DateTime.now().subtract(const Duration(days: 4)),
              colorValue: 0xFF34C759,
              points: const [
                LatLng(41.332000, 69.282500),
                LatLng(41.333200, 69.284500),
                LatLng(41.332200, 69.285800),
                LatLng(41.331000, 69.283800),
              ],
            ),
            // 5. Samarqand Darvoza Mall Parking
            ParkingZone(
              id: 'park_samarqand_darvoza_5',
              name: 'Samarqand Darvoza Yopiq Parkovkasi',
              isPaid: true,
              priceInfo: '6,000 so\'m/soat',
              capacity: 180,
              availableSpots: 35,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              colorValue: 0xFF007AFF,
              points: const [
                LatLng(41.320500, 69.222500),
                LatLng(41.321800, 69.224800),
                LatLng(41.320800, 69.226000),
                LatLng(41.319500, 69.223800),
              ],
            ),
          ],
        )) {
    loadFromSupabase();
  }

  Future<void> loadFromSupabase() async {
    try {
      final response = await SupabaseService.client
          .from('parking_zones')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        final zones = data.map((json) => ParkingZone.fromJson(json as Map<String, dynamic>)).toList();
        state = state.copyWith(savedZones: zones);
      }
    } catch (_) {}
  }

  void toggleDrawingMode() {
    state = state.copyWith(
      isDrawingMode: !state.isDrawingMode,
      draftPoints: state.isDrawingMode ? [] : state.draftPoints,
      clearSelectedZone: true,
    );
  }

  void addDraftPoint(LatLng point) {
    if (!state.isDrawingMode) return;
    state = state.copyWith(draftPoints: [...state.draftPoints, point]);
  }

  void undoLastPoint() {
    if (state.draftPoints.isEmpty) return;
    final updated = List<LatLng>.from(state.draftPoints)..removeLast();
    state = state.copyWith(draftPoints: updated);
  }

  void clearDraft() {
    state = state.copyWith(draftPoints: []);
  }

  bool saveCurrentZone({
    required String name,
    required bool isPaid,
    required String priceInfo,
    required int capacity,
  }) {
    if (state.draftPoints.length < 3) return false;

    final newZone = ParkingZone(
      id: 'park_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Shaxsiy Parkovka' : name.trim(),
      points: List<LatLng>.from(state.draftPoints),
      isPaid: isPaid,
      priceInfo: priceInfo,
      capacity: capacity,
      availableSpots: capacity > 5 ? capacity - 4 : capacity,
      createdAt: DateTime.now(),
      colorValue: isPaid ? 0xFF007AFF : 0xFF34C759,
    );

    state = state.copyWith(
      savedZones: [newZone, ...state.savedZones],
      draftPoints: [],
      isDrawingMode: false,
      selectedZone: newZone,
    );

    _persistToSupabase(newZone);
    return true;
  }

  Future<void> _persistToSupabase(ParkingZone zone) async {
    try {
      await SupabaseService.client.from('parking_zones').insert(zone.toSupabase());
    } catch (_) {}
  }

  void selectZone(ParkingZone? zone) {
    state = state.copyWith(selectedZone: zone, clearSelectedZone: zone == null);
  }

  void deleteZone(String id) {
    state = state.copyWith(
      savedZones: state.savedZones.where((z) => z.id != id).toList(),
      clearSelectedZone: state.selectedZone?.id == id,
    );
    _deleteFromSupabase(id);
  }

  Future<void> _deleteFromSupabase(String id) async {
    try {
      await SupabaseService.client.from('parking_zones').delete().eq('id', id);
    } catch (_) {}
  }
}

final parkingZoneProvider =
    StateNotifierProvider<ParkingZoneNotifier, ParkingZoneState>((ref) {
  return ParkingZoneNotifier();
});
