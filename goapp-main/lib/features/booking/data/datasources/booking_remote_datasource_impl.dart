import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/google_endpoints.dart';
import '../../../../core/utils/env.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/geo_point.dart';
import '../models/booking_route_model.dart';
import 'booking_remote_datasource.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _googleDio;
  final ApiClient _apiClient;

  BookingRemoteDataSourceImpl({
    Dio? googleDio,
    required ApiClient apiClient,
  })  : _googleDio = googleDio ??
            Dio(
              BaseOptions(
                baseUrl: GoogleEndpoints.routesBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            ),
        _apiClient = apiClient;

  @override
  Future<BookingRouteModel> fetchRoute({
    required GeoPoint pickup,
    required GeoPoint drop,
  }) async {
    final routesKey = Env.googleRoutesApiKey;
    final matrixKey = Env.googleRoutesMatrixApiKey;

    if (routesKey.isEmpty) {
      return const BookingRouteModel(
        encodedPolyline: '',
        distanceMeters: 0,
        durationSeconds: 0,
      );
    }

    final routeResponse = await _googleDio.post(
      GoogleEndpoints.routesCompute,
      data: {
        'origin': {
          'location': {
            'latLng': {'latitude': pickup.lat, 'longitude': pickup.lng},
          },
        },
        'destination': {
          'location': {
            'latLng': {'latitude': drop.lat, 'longitude': drop.lng},
          },
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'computeAlternativeRoutes': false,
        'units': 'METRIC',
      },
      options: Options(
        headers: {
          'X-Goog-Api-Key': routesKey,
          'X-Goog-FieldMask':
              'routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration',
        },
      ),
    );

    final routes = routeResponse.data['routes'] as List<dynamic>? ?? [];
    String encodedPolyline = '';
    int distanceMeters = 0;
    int durationSeconds = 0;

    if (routes.isNotEmpty) {
      final route = routes.first as Map<String, dynamic>;
      encodedPolyline = route['polyline']?['encodedPolyline'] as String? ?? '';
      distanceMeters = route['distanceMeters'] as int? ?? 0;
      durationSeconds = _parseDuration(route['duration']);
    }

    if (matrixKey.isNotEmpty) {
      try {
        final matrixResponse = await _googleDio.post(
          GoogleEndpoints.routesMatrix,
          data: {
            'origins': [
              {
                'waypoint': {
                  'location': {
                    'latLng': {'latitude': pickup.lat, 'longitude': pickup.lng},
                  },
                },
              },
            ],
            'destinations': [
              {
                'waypoint': {
                  'location': {
                    'latLng': {'latitude': drop.lat, 'longitude': drop.lng},
                  },
                },
              },
            ],
            'travelMode': 'DRIVE',
            'routingPreference': 'TRAFFIC_AWARE',
          },
          options: Options(
            headers: {
              'X-Goog-Api-Key': matrixKey,
              'X-Goog-FieldMask': 'distanceMeters,duration',
            },
          ),
        );
        final element = _extractMatrixElement(matrixResponse.data);
        if (element != null) {
          distanceMeters = element['distanceMeters'] as int? ?? distanceMeters;
          final parsedDuration = _parseDuration(element['duration']);
          if (parsedDuration != 0) durationSeconds = parsedDuration;
        }
      } catch (_) {
        // Non-fatal — use routes result
      }
    }

    return BookingRouteModel(
      encodedPolyline: encodedPolyline,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Future<String> bookRide({
    required BookingService vehicleType,
    required GeoPoint pickup,
    String? pickupAddress,
    required GeoPoint drop,
    String? dropAddress,
    required String encodedPolyline,
    required int distanceMeters,
    required int durationSeconds,
  }) async {
    final response = await _apiClient.post(
      '/rides/book',
      data: {
        'vehicleType': vehicleType.name,
        'pickup': {
          'lat': pickup.lat,
          'lng': pickup.lng,
          'address': pickupAddress,
        },
        'drop': {
          'lat': drop.lat,
          'lng': drop.lng,
          'address': dropAddress,
        },
        'encodedPolyline': encodedPolyline,
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
      },
    );
    return response.data['id'] as String;
  }

  Map<String, dynamic>? _extractMatrixElement(dynamic data) {
    if (data is List && data.isNotEmpty) {
      return data.first as Map<String, dynamic>?;
    }
    if (data is Map<String, dynamic>) {
      final elements = data['routeMatrix'] as List<dynamic>?;
      if (elements != null && elements.isNotEmpty) {
        return elements.first as Map<String, dynamic>?;
      }
    }
    return null;
  }

  int _parseDuration(dynamic value) {
    if (value is String && value.endsWith('s')) {
      return int.tryParse(value.replaceAll('s', '')) ?? 0;
    }
    if (value is int) return value;
    return 0;
  }
}
