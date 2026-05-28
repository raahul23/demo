import 'package:goapp/features/booking/domain/entities/booking_progress_state.dart';
import 'package:goapp/features/booking/domain/entities/booking_service.dart';
import 'package:goapp/features/booking/domain/entities/driver_info.dart';

class BookingProgress {
  final BookingProgressState state;
  final int? etaMin;
  final double? distanceKm;
  final DriverInfo? driver;
  final String? sessionKey;
  final BookingService? service;

  const BookingProgress({
    required this.state,
    this.etaMin,
    this.distanceKm,
    this.driver,
    this.sessionKey,
    this.service,
  });
}
