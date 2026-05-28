class FeedbackSubmission {
  final String driverName;
  final String vehicle;
  final String plateNumber;
  final String pickupLabel;
  final String dropLabel;
  final double distanceKm;
  final int durationMin;
  final int rating;
  final String? comment;

  const FeedbackSubmission({
    required this.driverName,
    required this.vehicle,
    required this.plateNumber,
    required this.pickupLabel,
    required this.dropLabel,
    required this.distanceKm,
    required this.durationMin,
    required this.rating,
    this.comment,
  });
}
