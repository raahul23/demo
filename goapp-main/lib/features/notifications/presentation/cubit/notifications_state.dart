class NotificationsState {
  final bool initialized;
  final int? lastArrivingPercent;
  final int? lastRidePercent;

  const NotificationsState({
    required this.initialized,
    required this.lastArrivingPercent,
    required this.lastRidePercent,
  });

  factory NotificationsState.initial() {
    return const NotificationsState(
      initialized: false,
      lastArrivingPercent: null,
      lastRidePercent: null,
    );
  }

  NotificationsState copyWith({
    bool? initialized,
    int? lastArrivingPercent,
    int? lastRidePercent,
    bool resetArrivingPercent = false,
    bool resetRidePercent = false,
  }) {
    return NotificationsState(
      initialized: initialized ?? this.initialized,
      lastArrivingPercent: resetArrivingPercent
          ? null
          : (lastArrivingPercent ?? this.lastArrivingPercent),
      lastRidePercent: resetRidePercent
          ? null
          : (lastRidePercent ?? this.lastRidePercent),
    );
  }
}
