import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/place_suggestion.dart';
import '../cubit/ride_search_cubit.dart';
import '../cubit/ride_search_state.dart';
import '../../../../core/maps/app_google_map.dart';
import '../../../../core/maps/vehicle_marker_controller.dart';
import '../../../../core/maps/map_style_loader.dart';
import '../../../../core/maps/map_view_mode.dart';
import '../../../../core/maps/map_viewport_helper.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../booking/domain/entities/geo_point.dart';
import '../../../booking/presentation/pages/booking_page.dart';
import '../../../booking/domain/entities/booking_service.dart';
import '../../../../core/di/injection.dart';
import '../../../activity/presentation/widgets/appbar.dart';


class RideSearchPage extends StatefulWidget {
  const RideSearchPage({super.key, this.initialService});

  final BookingService? initialService;

  @override
  State<RideSearchPage> createState() => _RideSearchPageState();
}

class _RideSearchPageState extends State<RideSearchPage>
    with WidgetsBindingObserver {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _pickupFocus = FocusNode();
  final _dropFocus = FocusNode();
  GoogleMapController? _mapController;
  final bool _isTest = const bool.fromEnvironment('FLUTTER_TEST');
  String? _mapStyle;
  bool _showingLocationDialog = false;
  int _lastMapViewChangeId = 0;
  int _lastLocationPromptId = 0;
  late final VehicleMarkerController _vehicleController =
      VehicleMarkerController(
        onUpdate: () {
          if (mounted) setState(() {});
        },
        animate: !_isTest,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyle();
    _loadVehicleIcons();
    _pickupFocus.addListener(() {
      if (_pickupFocus.hasFocus) {
        context.read<RideSearchCubit>().setActiveField(true);
      }
    });
    _dropFocus.addListener(() {
      if (_dropFocus.hasFocus) {
        context.read<RideSearchCubit>().setActiveField(false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pickupController.dispose();
    _dropController.dispose();
    _pickupFocus.dispose();
    _dropFocus.dispose();
    _mapController?.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _vehicleController.handleLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      context.read<RideSearchCubit>().retryIfPending();
    }
  }

  Future<void> _loadMapStyle() async {
    final style = await getIt<MapStyleLoader>().loadDefault();
    if (!mounted) return;
    setState(() => _mapStyle = style);
  }

  Future<void> _loadVehicleIcons() async {
    await _vehicleController.loadBikeIcon();
  }


  void _selectSuggestion(PlaceSuggestion suggestion) {
    context.read<RideSearchCubit>().selectSuggestion(suggestion);
  }

  void _showMessage(String text) {
    SnackBarUtils.show(context, text);
  }

  Future<void> _handleMapToggle() async {
    final cubit = context.read<RideSearchCubit>();
    await cubit.toggleMapView();
  }

  Future<void> _showLocationDialog() async {
    if (_showingLocationDialog) return;
    _showingLocationDialog = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Please allow location'),
        content: const Text(
          'Enable location permission to use current location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    _showingLocationDialog = false;
    if (!mounted) return;
    final cubit = context.read<RideSearchCubit>();
    if (result == true) {
      await cubit.openLocationSettings();
    } else {
      cubit.clearLocationPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Where to?'),
      body: BlocListener<RideSearchCubit, RideSearchState>(
        listener: (context, state) {
          if (_pickupController.text != state.pickupText) {
            _pickupController.text = state.pickupText;
          }
          if (_dropController.text != state.dropText) {
            _dropController.text = state.dropText;
          }
          if (state.message != null) {
            _showMessage(state.message!);
            context.read<RideSearchCubit>().clearMessage();
          }
          if (state.locationPromptId != _lastLocationPromptId) {
            _lastLocationPromptId = state.locationPromptId;
            if (state.needsLocationPermission) {
              _showLocationDialog();
            }
          }
          if (state.shouldAnimateVehicles) {
            final center = LatLng(state.pickupLat!, state.pickupLng!);
            final previous = _vehicleController.center;
            final bool changed = previous == null ||
                (previous.latitude - center.latitude).abs() > 0.00001 ||
                (previous.longitude - center.longitude).abs() > 0.00001;
            if (changed) {
              _vehicleController.start(center);
            }
          } else {
            _vehicleController.stop();
          }
          if (_mapController != null) {
            if (state.mapViewChangeId != _lastMapViewChangeId) {
              _lastMapViewChangeId = state.mapViewChangeId;
              if (state.mapViewMode == MapViewMode.both &&
                  state.pickupLat != null &&
                  state.pickupLng != null &&
                  state.dropLat != null &&
                  state.dropLng != null) {
                final bounds = MapViewportHelper.boundsFor(
                  pickup: LatLng(state.pickupLat!, state.pickupLng!),
                  drop: LatLng(state.dropLat!, state.dropLng!),
                );
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 60),
                );
              } else {
                final target = MapViewportHelper.targetFor(
                  mode: state.mapViewMode,
                  pickup: state.pickupLat != null && state.pickupLng != null
                      ? LatLng(state.pickupLat!, state.pickupLng!)
                      : null,
                  drop: state.dropLat != null && state.dropLng != null
                      ? LatLng(state.dropLat!, state.dropLng!)
                      : null,
                );
                if (target != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(target, 15),
                  );
                }
              }
            }
          }
        },
        child: BlocBuilder<RideSearchCubit, RideSearchState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
                    children: [
                      TextField(
                        controller: _pickupController,
                        focusNode: _pickupFocus,
                        decoration: const InputDecoration(
                          labelText: 'Pickup Location',
                          hintText: 'Enter pickup location',
                        ),
                        onChanged: context.read<RideSearchCubit>().updatePickup,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _dropController,
                        focusNode: _dropFocus,
                        decoration: const InputDecoration(
                          labelText: 'Drop Location',
                          hintText: 'Enter drop location',
                        ),
                        onChanged: context.read<RideSearchCubit>().updateDrop,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: BlocBuilder<RideSearchCubit, RideSearchState>(
                          builder: (context, state) {
                            final LatLng markerPos = state.isPickupActive
                                ? LatLng(
                                    state.pickupLat ?? 20.5937,
                                    state.pickupLng ?? 78.9629,
                                  )
                                : LatLng(
                                    state.dropLat ?? 20.5937,
                                    state.dropLng ?? 78.9629,
                                  );
                            final Set<Marker> markers = {
                              if (state.pickupLat != null &&
                                  state.pickupLng != null)
                                Marker(
                                  markerId: const MarkerId('pickup_marker'),
                                  position: LatLng(
                                    state.pickupLat!,
                                    state.pickupLng!,
                                  ),
                                  icon:
                                      BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen,
                                  ),
                                  draggable: true,
                                  onDragEnd: (pos) {
                                    context
                                        .read<RideSearchCubit>()
                                        .updateMarkerPositionFor(
                                          isPickup: true,
                                          position: pos,
                                        );
                                  },
                                  infoWindow:
                                      const InfoWindow(title: 'Pickup'),
                                ),
                              if (state.dropLat != null &&
                                  state.dropLng != null)
                                Marker(
                                  markerId: const MarkerId('drop_marker'),
                                  position: LatLng(
                                    state.dropLat!,
                                    state.dropLng!,
                                  ),
                                  icon:
                                      BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                  draggable: true,
                                  onDragEnd: (pos) {
                                    context
                                        .read<RideSearchCubit>()
                                        .updateMarkerPositionFor(
                                          isPickup: false,
                                          position: pos,
                                        );
                                  },
                                  infoWindow:
                                      const InfoWindow(title: 'Drop'),
                                ),
                              Marker(
                                markerId: const MarkerId('active_marker'),
                                position: markerPos,
                                draggable: true,
                                onDragEnd: (pos) {
                                  context
                                      .read<RideSearchCubit>()
                                      .updateMarkerPosition(pos);
                                },
                                infoWindow: InfoWindow(
                                  title: state.isPickupActive
                                      ? 'Pickup'
                                      : 'Drop',
                                ),
                              ),
                              if (state.shouldAnimateVehicles)
                                ..._vehicleController.markers,
                            };
                            return Stack(
                              children: [
                                AppGoogleMap(
                                  isTestOverride: _isTest,
                                  initialCameraPosition: CameraPosition(
                                    target: markerPos,
                                    zoom: 14,
                                  ),
                                  style: _mapStyle,
                                  markers: markers,
                                  gestureRecognizers: {
                                    Factory<OneSequenceGestureRecognizer>(
                                      () => EagerGestureRecognizer(),
                                    ),
                                  },
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                  },
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: FloatingActionButton(
                                    heroTag: 'ride_search_pickup_center',
                                    mini: true,
                                    onPressed: _handleMapToggle,
                                    child: Icon(
                                      (state.pickupLat != null &&
                                              state.pickupLng != null &&
                                              state.dropLat != null &&
                                              state.dropLng != null &&
                                              state.mapViewMode ==
                                                  MapViewMode.both)
                                          ? Icons.my_location
                                          : Icons.zoom_out_map,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.loading) const LinearProgressIndicator(),
                      if (state.suggestions.isNotEmpty ||
                          state.isPickupActive) ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            children: [
                              if (state.isPickupActive)
                                ListTile(
                                  leading: const Icon(Icons.my_location),
                                  title: const Text('Use current location'),
                                  onTap: context
                                      .read<RideSearchCubit>()
                                      .useCurrentLocation,
                                ),
                              ...state.suggestions.map(
                                (s) => ListTile(
                                  leading: const Icon(Icons.place_outlined),
                                  title: Text(s.description),
                                  onTap: () => _selectSuggestion(s),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  BlocBuilder<RideSearchCubit, RideSearchState>(
                    builder: (context, state) {
                      if (!state.canContinue) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final current =
                                      context.read<RideSearchCubit>().state;
                                  if (current.pickupLat == null ||
                                      current.pickupLng == null ||
                                      current.dropLat == null ||
                                      current.dropLng == null) {
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BookingPage(
                                        pickup: GeoPoint(
                                          lat: current.pickupLat!,
                                          lng: current.pickupLng!,
                                        ),
                                        drop: GeoPoint(
                                          lat: current.dropLat!,
                                          lng: current.dropLng!,
                                        ),
                                        pickupLabel: current.pickupText,
                                        dropLabel: current.dropText,
                                        initialService: widget.initialService,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Continue'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
