import '../../domain/entities/ride_activity.dart';

class ActivityState {
  final List<RideActivity> rides;
  final bool loading;
  final String? errorMessage;
  final String? receiptMessage;

  const ActivityState({
    required this.rides,
    required this.loading,
    required this.errorMessage,
    required this.receiptMessage,
  });

  factory ActivityState.initial() {
    return const ActivityState(
      rides: [],
      loading: true,
      errorMessage: null,
      receiptMessage: null,
    );
  }

  ActivityState copyWith({
    List<RideActivity>? rides,
    bool? loading,
    String? errorMessage,
    String? receiptMessage,
    bool clearError = false,
    bool clearReceipt = false,
  }) {
    return ActivityState(
      rides: rides ?? this.rides,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      receiptMessage:
          clearReceipt ? null : (receiptMessage ?? this.receiptMessage),
    );
  }
}
