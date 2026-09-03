import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapFilterType {
  all,
  gai,
  radar,
  kamera,
  parkovka,
}

class MapFilterNotifier extends StateNotifier<MapFilterType> {
  MapFilterNotifier() : super(MapFilterType.all);

  void toggleFilter(MapFilterType filter) {
    if (state == filter) {
      state = MapFilterType.all;
    } else {
      state = filter;
    }
  }

  void setFilter(MapFilterType filter) {
    state = filter;
  }

  void clear() {
    state = MapFilterType.all;
  }
}

final mapFilterProvider =
    StateNotifierProvider<MapFilterNotifier, MapFilterType>((ref) {
  return MapFilterNotifier();
});
