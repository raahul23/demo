import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/maps/app_google_map.dart';
import '../../../../core/maps/map_view_mode.dart';
import '../../../../core/utils/polyline.dart';
import '../../domain/entities/driver_search_status.dart';
import '../cubit/booking_state.dart';

class BookingMapSection extends StatelessWidget {
  final BookingState state;
  final bool isTest;
  final String? mapStyle;
  final Set<Marker> vehicleMarkers;
  final ValueChanged<GoogleMapController> onMapCreated;
  final VoidCallback onToggleMapView;

  const BookingMapSection({
    super.key,
    required this.state,
    required this.isTest,
    required this.mapStyle,
    required this.vehicleMarkers,
    required this.onMapCreated,
    required this.onToggleMapView,
  });

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(state.pickup.lat, state.pickup.lng);
    final drop = LatLng(state.drop.lat, state.drop.lng);
    final points = PolylineDecoder.decode(state.route?.encodedPolyline ?? '');
    final driverPath = state.driverRoutePath
        .map((point) => LatLng(point.lat, point.lng))
        .toList();

    return Stack(
      children: [
        AppGoogleMap(
          isTestOverride: isTest,
          testPlaceholderKey: const Key('booking-map-placeholder'),
          initialCameraPosition: CameraPosition(
            target: pickup,
            zoom: 14,
          ),
          style: mapStyle,
          markers: {
            if (state.driverSearchStatus != DriverSearchStatus.inRide &&
                state.driverSearchStatus != DriverSearchStatus.completed)
              Marker(
                markerId: const MarkerId('pickup_marker'),
                position: pickup,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: InfoWindow(
                  title: 'Pickup',
                  snippet: state.pickupLabel,
                ),
              ),
            Marker(
              markerId: const MarkerId('drop_marker'),
              position: drop,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: 'Drop',
                snippet: state.dropLabel,
              ),
            ),
            if ((state.driverSearchStatus == DriverSearchStatus.arriving ||
                    state.driverSearchStatus == DriverSearchStatus.inRide ||
                    state.driverSearchStatus == DriverSearchStatus.completed) &&
                state.driverLocation != null)
              Marker(
                markerId: const MarkerId('driver_marker'),
                position: LatLng(
                  state.driverLocation!.lat,
                  state.driverLocation!.lng,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
                infoWindow: const InfoWindow(title: 'Driver'),
              ),
            ...vehicleMarkers,
          },
          polylines: {
            if (points.isNotEmpty &&
                state.driverSearchStatus != DriverSearchStatus.inRide &&
                state.driverSearchStatus != DriverSearchStatus.completed)
              Polyline(
                polylineId: const PolylineId('route_polyline'),
                points: points,
                color: Colors.black87,
                width: 5,
              ),
            if (driverPath.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('driver_route_polyline'),
                points: driverPath,
                color: Colors.blueAccent,
                width: 4,
              ),
          },
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: onMapCreated,
        ),
        Positioned(
          right: 12,
          top: 12,
          child: FloatingActionButton(
            heroTag: 'booking_pickup_center',
            mini: true,
            onPressed: onToggleMapView,
            child: Icon(
              state.mapViewMode == MapViewMode.both
                  ? Icons.my_location
                  : Icons.zoom_out_map,
            ),
          ),
        ),
      ],
    );
  }
}
