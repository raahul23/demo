import '../../../booking/domain/entities/booking_service.dart';

class ServiceItem {
  final String id;
  final String name;
  final String iconKey;
  final String? description;
  final BookingService? bookingService;
  final bool featured;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.iconKey,
    this.description,
    this.bookingService,
    this.featured = false,
  });
}
