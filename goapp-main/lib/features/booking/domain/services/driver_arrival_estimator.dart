class DriverArrivalEstimate {
  final double distanceKm;
  final int etaMin;

  const DriverArrivalEstimate({
    required this.distanceKm,
    required this.etaMin,
  });
}

class DriverArrivalEstimator {
  const DriverArrivalEstimator();

  DriverArrivalEstimate estimate({
    required double? tripDistanceKm,
    required int? tripDurationMin,
  }) {
    final baseDistance = (tripDistanceKm ?? 1.0) * 0.35 + 0.4;
    final distanceKm = baseDistance.clamp(0.6, 4.0);
    final baseEta = ((tripDurationMin ?? 8) * 0.35).round();
    final etaMin = (baseEta + (distanceKm * 2).round()).clamp(3, 15);
    return DriverArrivalEstimate(
      distanceKm: distanceKm.toDouble(),
      etaMin: etaMin,
    );
  }
}
