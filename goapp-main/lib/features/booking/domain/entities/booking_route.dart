class BookingRoute {
  final String encodedPolyline;
  final int distanceMeters;
  final int durationSeconds;

  const BookingRoute({
    required this.encodedPolyline,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
