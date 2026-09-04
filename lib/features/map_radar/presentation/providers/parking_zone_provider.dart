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
      : super(const ParkingZoneState(savedZones: [])) {
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
