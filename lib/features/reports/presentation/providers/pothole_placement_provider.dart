import 'package:flutter_riverpod/flutter_riverpod.dart';

class PotholePlacementState {
  final bool isPlacing;

  const PotholePlacementState({this.isPlacing = false});
}

class PotholePlacementNotifier extends StateNotifier<PotholePlacementState> {
  PotholePlacementNotifier() : super(const PotholePlacementState());

  void startPlacing() {
    state = const PotholePlacementState(isPlacing: true);
  }

  void cancelPlacing() {
    state = const PotholePlacementState(isPlacing: false);
  }
}

final potholePlacementProvider =
    StateNotifierProvider<PotholePlacementNotifier, PotholePlacementState>((ref) {
  return PotholePlacementNotifier();
});
