import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../booking/domain/entities/booking_service.dart';
import '../../domain/entities/service_item.dart';
import 'services_remote_datasource.dart';

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final ApiClient _apiClient;

  ServicesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ServiceItem>> fetchServices() async {
    try {
      final response = await _apiClient.get('/services');
      final List<dynamic> data = response.data as List<dynamic>? ?? [];

      return data
          .map((json) => _fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      return _fallback();
    }
  }

  ServiceItem _fromJson(Map<String, dynamic> json) {
    final bookingServiceStr = json['booking_service'] as String?;
    BookingService? bookingService;
    switch (bookingServiceStr) {
      case 'bike':
        bookingService = BookingService.bike;
      case 'auto':
        bookingService = BookingService.auto;
      case 'car':
        bookingService = BookingService.car;
    }

    return ServiceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['icon_key'] as String,
      description: json['description'] as String?,
      bookingService: bookingService,
      featured: json['featured'] as bool? ?? false,
    );
  }

  List<ServiceItem> _fallback() => const [
        ServiceItem(
          id: 'bike',
          name: 'Bike',
          iconKey: 'bike',
          description: 'Quick solo rides',
          bookingService: BookingService.bike,
          featured: true,
        ),
        ServiceItem(
          id: 'auto',
          name: 'Auto',
          iconKey: 'auto',
          description: 'Affordable autos',
          bookingService: BookingService.auto,
          featured: true,
        ),
        ServiceItem(
          id: 'car',
          name: 'Car',
          iconKey: 'car',
          description: 'Comfortable cars',
          bookingService: BookingService.car,
          featured: true,
        ),
      ];
}
