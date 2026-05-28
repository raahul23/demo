class RideActivity {
  final String id;
  final RideActivityStatus status;
  final String pickupLabel;
  final String dropLabel;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceKm;
  final int durationMin;
  final DriverSummary driver;
  final PaymentSummary payment;
  final RideCancelledBy? cancelledBy;
  final String supportNote;
  final String receiptUrl;

  const RideActivity({
    required this.id,
    required this.status,
    required this.pickupLabel,
    required this.dropLabel,
    required this.startedAt,
    required this.endedAt,
    required this.distanceKm,
    required this.durationMin,
    required this.driver,
    required this.payment,
    this.cancelledBy,
    required this.supportNote,
    required this.receiptUrl,
  });
}

class DriverSummary {
  final String name;
  final String vehicle;
  final String plate;
  final double rating;

  const DriverSummary({
    required this.name,
    required this.vehicle,
    required this.plate,
    required this.rating,
  });
}

class PaymentSummary {
  final double fare;
  final String method;
  final String transactionId;

  const PaymentSummary({
    required this.fare,
    required this.method,
    required this.transactionId,
  });
}

enum RideActivityStatus { completed, cancelled }

enum RideCancelledBy { rider, driver }
