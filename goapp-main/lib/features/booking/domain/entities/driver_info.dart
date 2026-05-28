import 'booking_service.dart';

class DriverInfo {
  final String name;
  final String vehicleModel;
  final String plateNumber;
  final String otp;
  final String phone;
  final BookingService service;

  const DriverInfo({
    required this.name,
    required this.vehicleModel,
    required this.plateNumber,
    required this.otp,
    required this.phone,
    required this.service,
  });
}
