import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppGoogleMap extends StatelessWidget {
  const AppGoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.onMapCreated,
    this.style,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.showTestPlaceholder = true,
    this.isTestOverride,
    this.testPlaceholderText = 'Map disabled in tests',
    this.testPlaceholderKey,
    this.gestureRecognizers,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
    this.compassEnabled = false,
    this.padding,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final String? style;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool showTestPlaceholder;
  final bool? isTestOverride;
  final String testPlaceholderText;
  final Key? testPlaceholderKey;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bool isTest =
        isTestOverride ?? const bool.fromEnvironment('FLUTTER_TEST');

    if (isTest && showTestPlaceholder) {
      return Center(
        child: Text(
          testPlaceholderText,
          key: testPlaceholderKey,
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      markers: markers,
      polylines: polylines,
      onMapCreated: onMapCreated,
      style: style,
      myLocationEnabled: myLocationEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
      mapToolbarEnabled: mapToolbarEnabled,
      compassEnabled: compassEnabled,
      padding: padding ?? EdgeInsets.zero,
      gestureRecognizers:
          gestureRecognizers ?? const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }
}
