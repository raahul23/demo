import 'booking_service.dart';

class FareQuote {
  final double baseFare;
  final Map<BookingService, double> servicePrices;

  const FareQuote({
    required this.baseFare,
    required this.servicePrices,
  });
}
