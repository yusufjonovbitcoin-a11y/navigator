import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';

class ReportAdjustmentState {
  final bool isActive;
  final String reportId;
  final ReportType? type;
  final LatLng currentPos;
  final int remainingMoves;
  final int totalMoves;
  final bool isDragging;
  final String? toastMessage;

  const ReportAdjustmentState({
    this.isActive = false,
    this.reportId = '',
    this.type,
    this.currentPos = const LatLng(41.2995, 69.2401),
    this.remainingMoves = 2,
    this.totalMoves = 2,
    this.isDragging = false,
    this.toastMessage,
  });

  ReportAdjustmentState copyWith({
    bool? isActive,
    String? reportId,
    ReportType? type,
    LatLng? currentPos,
    int? remainingMoves,
    int? totalMoves,
    bool? isDragging,
    String? toastMessage,
    bool clearToast = false,
  }) {
    return ReportAdjustmentState(
      isActive: isActive ?? this.isActive,
      reportId: reportId ?? this.reportId,
      type: type ?? this.type,
      currentPos: currentPos ?? this.currentPos,
      remainingMoves: remainingMoves ?? this.remainingMoves,
      totalMoves: totalMoves ?? this.totalMoves,
      isDragging: isDragging ?? this.isDragging,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }
}

class ReportAdjustmentNotifier extends StateNotifier<ReportAdjustmentState> {
  ReportAdjustmentNotifier() : super(const ReportAdjustmentState());

  void start({
    required String reportId,
    required ReportType type,
    required LatLng initialPos,
    int maxMoves = 2,
  }) {
    state = ReportAdjustmentState(
      isActive: true,
      reportId: reportId,
      type: type,
      currentPos: initialPos,
      remainingMoves: maxMoves,
      totalMoves: maxMoves,
      isDragging: false,
      toastMessage: null,
    );
  }

  void updateCurrentPos(LatLng pos) {
    if (!state.isActive) return;
    state = state.copyWith(currentPos: pos, isDragging: true);
  }

  void setIsDragging(bool isDragging) {
    if (!state.isActive) return;
    state = state.copyWith(isDragging: isDragging);
  }

  /// Called on drag end or map tap. Decrements remaining moves.
  /// Returns true if all moves are now used up.
  bool commitMove() {
    if (!state.isActive || state.remainingMoves <= 0) return true;
    final nextMoves = state.remainingMoves - 1;
    final isDone = nextMoves <= 0;

    state = state.copyWith(
      remainingMoves: nextMoves,
      isDragging: false,
      toastMessage: null,
    );
    return isDone;
  }

  void clearToast() {
    state = state.copyWith(clearToast: true);
  }

  void cancel() {
    state = const ReportAdjustmentState(isActive: false);
  }

  void finish() {
    state = const ReportAdjustmentState(isActive: false);
  }
}

final reportAdjustmentProvider =
    StateNotifierProvider<ReportAdjustmentNotifier, ReportAdjustmentState>((ref) {
  return ReportAdjustmentNotifier();
});
