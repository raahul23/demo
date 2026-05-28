import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/booking_progress.dart';
import '../../domain/entities/booking_progress_state.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/driver_info.dart';

class BookingProgressStorage {
  static const _stateKey = 'booking_progress_state';
  static const _etaKey = 'booking_progress_eta_min';
  static const _distanceKey = 'booking_progress_distance_km';
  static const _driverNameKey = 'booking_progress_driver_name';
  static const _driverVehicleKey = 'booking_progress_driver_vehicle';
  static const _driverPlateKey = 'booking_progress_driver_plate';
  static const _driverPhoneKey = 'booking_progress_driver_phone';
  static const _driverOtpKey = 'booking_progress_driver_otp';
  static const _sessionKey = 'booking_progress_session';
  static const _serviceKey = 'booking_progress_service';

  final SharedPreferences prefs;

  BookingProgressStorage(this.prefs);

  BookingProgress? get() {
    final raw = prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) return null;
    final state = bookingProgressStateFromString(raw);
    final eta = prefs.getInt(_etaKey);
    double? distance;
    try {
      distance = prefs.getDouble(_distanceKey);
    } catch (_) {
      distance = null;
    }
    distance ??= double.tryParse(prefs.getString(_distanceKey) ?? '');
    DriverInfo? driver;
    final name = prefs.getString(_driverNameKey);
    BookingService? service;
    final serviceRaw = prefs.getString(_serviceKey);
    if (serviceRaw != null && serviceRaw.isNotEmpty) {
      service = BookingService.values.firstWhere(
        (value) => value.name == serviceRaw,
        orElse: () => BookingService.bike,
      );
    }
    if (name != null && name.isNotEmpty) {
      driver = DriverInfo(
        name: name,
        vehicleModel: prefs.getString(_driverVehicleKey) ?? 'Bike',
        plateNumber: prefs.getString(_driverPlateKey) ?? 'TN 00 XX 0000',
        otp: prefs.getString(_driverOtpKey) ?? '0000',
        phone: prefs.getString(_driverPhoneKey) ?? '+91 90000 0000',
        service: service ?? BookingService.bike,
      );
    }
    return BookingProgress(
      state: state,
      etaMin: eta,
      distanceKm: distance,
      driver: driver,
      sessionKey: prefs.getString(_sessionKey),
      service: service,
    );
  }

  Future<void> save(BookingProgress progress) async {
    await prefs.setString(
      _stateKey,
      bookingProgressStateToString(progress.state),
    );
    if (progress.etaMin != null) {
      await prefs.setInt(_etaKey, progress.etaMin!);
    }
    if (progress.distanceKm != null) {
      await prefs.setDouble(_distanceKey, progress.distanceKm!);
    }
    final driver = progress.driver;
    if (driver != null) {
      await prefs.setString(_driverNameKey, driver.name);
      await prefs.setString(_driverVehicleKey, driver.vehicleModel);
      await prefs.setString(_driverPlateKey, driver.plateNumber);
      await prefs.setString(_driverPhoneKey, driver.phone);
      await prefs.setString(_driverOtpKey, driver.otp);
    } else {
      await prefs.remove(_driverNameKey);
      await prefs.remove(_driverVehicleKey);
      await prefs.remove(_driverPlateKey);
      await prefs.remove(_driverPhoneKey);
      await prefs.remove(_driverOtpKey);
    }
    final sessionKey = progress.sessionKey;
    if (sessionKey != null && sessionKey.isNotEmpty) {
      await prefs.setString(_sessionKey, sessionKey);
    } else {
      await prefs.remove(_sessionKey);
    }
    final service = progress.service;
    if (service != null) {
      await prefs.setString(_serviceKey, service.name);
    } else {
      await prefs.remove(_serviceKey);
    }
  }

  Future<void> clear() async {
    await prefs.remove(_stateKey);
    await prefs.remove(_etaKey);
    await prefs.remove(_distanceKey);
    await prefs.remove(_driverNameKey);
    await prefs.remove(_driverVehicleKey);
    await prefs.remove(_driverPlateKey);
    await prefs.remove(_driverPhoneKey);
    await prefs.remove(_driverOtpKey);
    await prefs.remove(_sessionKey);
    await prefs.remove(_serviceKey);
  }
}
