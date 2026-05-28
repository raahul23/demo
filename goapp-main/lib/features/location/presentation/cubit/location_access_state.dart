class LocationAccessState {
  final bool requesting;
  final bool loading;
  final bool navigateHome;
  final int navigateToken;

  const LocationAccessState({
    required this.requesting,
    required this.loading,
    required this.navigateHome,
    required this.navigateToken,
  });

  factory LocationAccessState.initial() {
    return const LocationAccessState(
      requesting: false,
      loading: false,
      navigateHome: false,
      navigateToken: 0,
    );
  }

  LocationAccessState copyWith({
    bool? requesting,
    bool? loading,
    bool? navigateHome,
    int? navigateToken,
    bool resetNavigate = false,
  }) {
    return LocationAccessState(
      requesting: requesting ?? this.requesting,
      loading: loading ?? this.loading,
      navigateHome:
          resetNavigate ? false : (navigateHome ?? this.navigateHome),
      navigateToken: navigateToken ?? this.navigateToken,
    );
  }
}
