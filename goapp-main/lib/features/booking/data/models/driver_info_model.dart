import '../../domain/entities/driver_info.dart';
import '../../domain/entities/booking_service.dart';

class DriverInfoModel extends DriverInfo {
  const DriverInfoModel({
    required super.name,
    required super.vehicleModel,
    required super.plateNumber,
    required super.otp,
    required super.phone,
    required super.service,
  });

  factory DriverInfoModel.fromJson(
    Map<String, dynamic> json, {
    BookingService fallbackService = BookingService.bike,
  }) {
    final serviceStr = json['service'] as String? ?? '';
    final BookingService service;
    switch (serviceStr) {
      case 'auto':
        service = BookingService.auto;
      case 'car':
        service = BookingService.car;
      default:
        service = fallbackService;
    }

    return DriverInfoModel(
      name: json['name'] as String? ?? 'Driver',
      vehicleModel: json['vehicle_model'] as String? ?? 'Vehicle',
      plateNumber: json['plate_number'] as String? ?? 'N/A',
      otp: json['otp'] as String? ?? '0000',
      phone: json['phone'] as String? ?? '',
      service: service,
    );
  }

  factory DriverInfoModel.mock(BookingService service) {
    switch (service) {
      case BookingService.auto:
        return const DriverInfoModel(
          name: 'Karan Auto',
          vehicleModel: 'Bajaj RE',
          plateNumber: 'TN 09 AB 4412',
          otp: '4821',
          phone: '+91 90000 4412',
          service: BookingService.auto,
        );
      case BookingService.car:
        return const DriverInfoModel(
          name: 'Anita',
          vehicleModel: 'Swift Dzire',
          plateNumber: 'TN 10 XY 9012',
          otp: '6395',
          phone: '+91 90000 9012',
          service: BookingService.car,
        );
      case BookingService.bike:
        return const DriverInfoModel(
          name: 'Raj',
          vehicleModel: 'Hero Splendor',
          plateNumber: 'TN 12 JK 1204',
          otp: '1537',
          phone: '+91 90000 1204',
          service: BookingService.bike,
        );
    }
  }
}
