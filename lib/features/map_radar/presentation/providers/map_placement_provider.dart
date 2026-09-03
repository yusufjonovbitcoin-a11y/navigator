import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/presentation/widgets/add_custom_object_sheet.dart';

class MapPlacementState {
  final CustomObjectType? activeType;
  final bool isPlacing;

  const MapPlacementState({
    this.activeType,
    this.isPlacing = false,
  });

  MapPlacementState copyWith({
    CustomObjectType? activeType,
    bool? isPlacing,
  }) {
    return MapPlacementState(
      activeType: activeType,
      isPlacing: isPlacing ?? this.isPlacing,
    );
  }
}

class MapPlacementNotifier extends StateNotifier<MapPlacementState> {
  MapPlacementNotifier() : super(const MapPlacementState());

  void startPlacing(CustomObjectType type) {
    state = MapPlacementState(activeType: type, isPlacing: true);
  }

  void cancelPlacing() {
    state = const MapPlacementState(activeType: null, isPlacing: false);
  }
}

final mapPlacementProvider =
    StateNotifierProvider<MapPlacementNotifier, MapPlacementState>((ref) {
  return MapPlacementNotifier();
});
