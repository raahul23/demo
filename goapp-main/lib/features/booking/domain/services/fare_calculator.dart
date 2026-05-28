import '../entities/booking_service.dart';
import '../entities/fare_quote.dart';

class FareCalculator {
  const FareCalculator({
    this.baseFare = 30,
    this.perKm = 12,
    this.perMin = 2,
    this.bikeMultiplier = 0.8,
    this.autoMultiplier = 1.0,
    this.carMultiplier = 1.3,
  });

  final double baseFare;
  final double perKm;
  final double perMin;
  final double bikeMultiplier;
  final double autoMultiplier;
  final double carMultiplier;

  FareQuote calculate({
    required int distanceMeters,
    required int durationSeconds,
  }) {
    final double distanceKm = distanceMeters / 1000;
    final double durationMin = durationSeconds / 60;
    final double total = baseFare + (distanceKm * perKm) + (durationMin * perMin);
    return FareQuote(
      baseFare: total,
      servicePrices: {
        BookingService.bike: total * bikeMultiplier,
        BookingService.auto: total * autoMultiplier,
        BookingService.car: total * carMultiplier,
      },
    );
  }
}
