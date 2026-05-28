import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../domain/entities/geo_point.dart';
import 'driver_tracking_socket_datasource.dart';

class DriverTrackingSocketDataSourceImpl
    implements DriverTrackingSocketDataSource {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  io.Socket? _socket;
  StreamController<GeoPoint>? _controller;
  String? _currentRideId;

  DriverTrackingSocketDataSourceImpl({
    required this.baseUrl,
    required this.tokenProvider,
  });

  @override
  Stream<GeoPoint> connect({required String rideId}) {
    // Clean up any existing connection
    _socket?.disconnect();
    _socket?.dispose();
    _controller?.close();

    _currentRideId = rideId;
    _controller = StreamController<GeoPoint>.broadcast(
      onCancel: disconnect,
    );

    // Init socket asynchronously — stream is returned immediately
    _initSocket(rideId);

    return _controller!.stream;
  }

  Future<void> _initSocket(String rideId) async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) {
      // No auth token — fall back gracefully (stream stays open, no data)
      return;
    }

    try {
      _socket = io.io(
        baseUrl,
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'auth': <String, dynamic>{'token': token},
        },
      );

      _socket!.onConnect((_) {
        // Subscribe to this ride's room
        _socket!.emit('ride:subscribe', rideId);
      });

      _socket!.on('ride:driverLocation', (dynamic data) {
        if (_controller == null || _controller!.isClosed) return;
        try {
          final map = data is List
              ? data[0] as Map<String, dynamic>
              : data as Map<String, dynamic>;
          final lat = (map['lat'] as num?)?.toDouble();
          final lng = (map['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            _controller!.add(GeoPoint(lat: lat, lng: lng));
          }
        } catch (_) {
          // Ignore malformed location data
        }
      });

      _socket!.onDisconnect((_) {
        // Don't close controller on disconnect — may reconnect
      });

      _socket!.onConnectError((error) {
        // Connection failed — stream stays open, simulation continues as fallback
      });

      _socket!.connect();
    } catch (_) {
      // If socket setup fails, stream stays open silently
    }
  }

  @override
  Future<void> disconnect() async {
    if (_currentRideId != null) {
      _socket?.emit('ride:unsubscribe', _currentRideId);
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRideId = null;

    if (_controller != null && !_controller!.isClosed) {
      await _controller!.close();
    }
    _controller = null;
  }
}
