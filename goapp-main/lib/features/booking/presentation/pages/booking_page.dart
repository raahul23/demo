import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/maps/map_style_loader.dart';
import '../../../../core/maps/map_view_mode.dart';
import '../../../../core/maps/map_viewport_helper.dart';
import '../../../../core/maps/vehicle_marker_controller.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/services/notification_permission_service.dart';
import '../../domain/entities/driver_search_status.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/services/driver_arrival_estimator.dart';
import '../../domain/services/driver_tracking_service.dart';
import '../../domain/services/fare_calculator.dart';
import '../../domain/usecases/get_booking_route_usecase.dart';
import '../../domain/usecases/get_driver_info_usecase.dart';
import '../../../feedback/domain/entities/feedback_submission.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../booking_flow_coordinator.dart';
import '../booking_progress_controller.dart';
import '../widgets/driver_search_sheet.dart';
import '../widgets/notification_permission_sheet.dart';
import '../widgets/booking_bottom_panel.dart';
import '../widgets/booking_map_section.dart';
import '../../../payment/presentation/pages/payment_page.dart';
import '../../../activity/presentation/widgets/appbar.dart';

class BookingPage extends StatefulWidget {
  final GeoPoint pickup;
  final GeoPoint drop;
  final String pickupLabel;
  final String dropLabel;
  final BookingCubit? cubit;
  final bool? isTestOverride;
  final bool autoStartSearch;
  final BookingService? initialService;
  final bool debugManualState;

  const BookingPage({
    super.key,
    required this.pickup,
    required this.drop,
    required this.pickupLabel,
    required this.dropLabel,
    this.cubit,
    this.isTestOverride,
    this.autoStartSearch = false,
    this.initialService,
    this.debugManualState = false,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  String? _mapStyle;
  int _lastMapViewChangeId = 0;
  bool _searchSheetOpen = false;
  bool _vehiclesActive = true;
  bool _notificationSheetOpen = false;
  bool _notificationRequestInFlight = false;
  int _notificationDeniedCount = 0;
  bool _isForeground = true;
  bool _autoStartHandled = false;
  BookingCubit? _bookingCubit;
  late final VehicleMarkerController _vehicleController =
      VehicleMarkerController(
        onUpdate: () {
          if (mounted) setState(() {});
        },
        animate: !(widget.isTestOverride ??
            const bool.fromEnvironment('FLUTTER_TEST')),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyle();
    _loadVehicleIcons();
    _vehicleController.start(
      LatLng(widget.pickup.lat, widget.pickup.lng),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _vehicleController.handleLifecycle(state);
    unawaited(_bookingCubit?.handleLifecycle(state));
    _isForeground = state == AppLifecycleState.resumed;
  }

  void _applyMapView(BookingState state) {
    if (_mapController == null) return;
    final pickup = LatLng(state.pickup.lat, state.pickup.lng);
    final drop = LatLng(state.drop.lat, state.drop.lng);
    if (state.mapViewMode == MapViewMode.both) {
      final bounds = MapViewportHelper.boundsFor(
        pickup: pickup,
        drop: drop,
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 60),
      );
    } else {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(pickup, 16),
      );
    }
  }

  Future<void> _loadMapStyle() async {
    final style = await getIt<MapStyleLoader>().loadBooking();
    if (!mounted) return;
    setState(() => _mapStyle = style);
  }

  Future<void> _loadVehicleIcons() async {
    await _vehicleController.loadBikeIcon();
  }

  void _syncVehicleController(BookingState state) {
    final shouldShowVehicles =
        state.driverSearchStatus == DriverSearchStatus.searching;
    if (shouldShowVehicles && !_vehiclesActive) {
      _vehiclesActive = true;
      _vehicleController.start(
        LatLng(state.pickup.lat, state.pickup.lng),
      );
    } else if (!shouldShowVehicles && _vehiclesActive) {
      _vehiclesActive = false;
      _vehicleController.stop(notify: false);
    }
  }

  void _openSearchSheet(BuildContext context, BookingState state) {
    if (_searchSheetOpen) return;
    _searchSheetOpen = true;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => DriverSearchSheet(
          onCancel: () => context.read<BookingCubit>().cancelDriverSearch(),
          service: state.selectedService,
        ),
      ).whenComplete(() {
        _searchSheetOpen = false;
      }),
    );
  }

  void _showDriverAcceptedDialog(BuildContext context) {
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        unawaited(
          Future.delayed(const Duration(seconds: 2), () {
            if (!dialogContext.mounted) return;
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          }),
        );
        return AlertDialog(
          title: const Text('Driver accepted your ride'),
          content: const Text('Your driver is on the way.'),
         
        );
      },
    ));
  }

  Future<void> _showNotificationSheet(BuildContext context) async {
    if (_notificationSheetOpen) return;
    _notificationSheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return NotificationPermissionSheet(
          onAllow: () async {
            await _requestNotificationPermission(sheetContext);
          },
        );
      },
    ).whenComplete(() {
      _notificationSheetOpen = false;
    });
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    if (_notificationRequestInFlight) return;
    _notificationRequestInFlight = true;
    final service = getIt<NotificationPermissionService>();
    final status = await service.request();
    _notificationRequestInFlight = false;
    if (!context.mounted) return;
    if (status == NotificationPermissionStatus.granted) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      final cubit = _bookingCubit;
      if (cubit != null) {
        cubit.startDriverSearch();
      }
      return;
    }
    _notificationDeniedCount += 1;
    if (_notificationDeniedCount >= 2) {
      await service.openSettings();
    }
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleBookNow(BuildContext context) async {
    final service = getIt<NotificationPermissionService>();
    final status = await service.check();
    if (!context.mounted) return;
    if (status == NotificationPermissionStatus.granted) {
      context.read<BookingCubit>().startDriverSearch();
      return;
    }
    await _showNotificationSheet(context);
  }

  Future<void> _handleDriverSearchState(
    BuildContext context,
    BookingState state,
  ) async {
    if (widget.debugManualState) {
      if (state.driverSearchStatus == DriverSearchStatus.searching) {
        _openSearchSheet(context, state);
        return;
      }
      if (state.driverSearchStatus == DriverSearchStatus.idle) {
        if (_searchSheetOpen && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
      return;
    }
    if (state.driverSearchStatus == DriverSearchStatus.searching) {
      _openSearchSheet(context, state);
      return;
    }
    if (state.driverSearchStatus == DriverSearchStatus.idle) {
      if (_searchSheetOpen && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    if (state.driverSearchStatus == DriverSearchStatus.found) {
      if (_searchSheetOpen && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      unawaited(context.read<BookingCubit>().markDriverArriving());
      if (_isForeground) {
        _showDriverAcceptedDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTest =
        widget.isTestOverride ?? const bool.fromEnvironment('FLUTTER_TEST');
    final Widget content = MultiBlocListener(
      listeners: [
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (_mapController == null) return;
            if (state.mapViewChangeId != _lastMapViewChangeId) {
              _lastMapViewChangeId = state.mapViewChangeId;
              _applyMapView(state);
            }
          },
        ),
        BlocListener<BookingCubit, BookingState>(
          listenWhen: (previous, current) =>
              previous.driverSearchStatus != current.driverSearchStatus,
          listener: (context, state) {
            unawaited(_handleDriverSearchState(context, state));
          },
        ),
      ],
      child: Scaffold(
        appBar: const AppAppBar(title: 'Booking'),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  _syncVehicleController(state);
                  return BookingMapSection(
                    state: state,
                    isTest: isTest,
                    mapStyle: _mapStyle,
                    vehicleMarkers:
                        _vehiclesActive ? _vehicleController.markers : {},
                    onToggleMapView:
                        context.read<BookingCubit>().toggleMapView,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _applyMapView(state);
                    },
                  );
                },
              ),
            ),
            BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                if (state.loading) {
                  return const LinearProgressIndicator();
                }
                return BookingBottomPanel(
                  state: state,
                  onBookNow: () => _handleBookNow(context),
                  onCancelRide: context.read<BookingCubit>().cancelRide,
                  onCallDriver: () => SnackBarUtils.show(
                    context,
                    'Calling ${state.driverInfo?.name ?? 'driver'}',
                  ),
                  onMessageDriver: () => SnackBarUtils.show(
                    context,
                    'Messaging ${state.driverInfo?.name ?? 'driver'}',
                  ),
                  onEmergency: () => SnackBarUtils.show(
                    context,
                    'Emergency assistance requested',
                  ),
                  onSos: () => SnackBarUtils.show(
                    context,
                    'SOS sent',
                  ),
                  onHelp: () => SnackBarUtils.show(
                    context,
                    'Help requested',
                  ),
                  onPayment: () {
                    final amount = state.selectedFare ??
                        state.fareQuote?.baseFare ??
                        0;
                    final driver = state.driverInfo;
                    if (driver == null) {
                      SnackBarUtils.show(context, 'Driver info missing');
                      return;
                    }
                    final summary = FeedbackSubmission(
                      driverName: driver.name,
                      vehicle: driver.vehicleModel,
                      plateNumber: driver.plateNumber,
                      pickupLabel: state.pickupLabel,
                      dropLabel: state.dropLabel,
                      distanceKm: state.distanceKm ?? 0,
                      durationMin: state.durationMin ?? 0,
                      rating: 0,
                      comment: null,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          amount: amount,
                          feedbackSummary: summary,
                        ),
                      ),
                    );
                  },
                  lockServiceSelection: widget.initialService != null,
                  onSelectService:
                      context.read<BookingCubit>().toggleService,
                );
              },
            ),
          ],
        ),
      ),
    );

    return MultiBlocProvider(
      providers: [
        if (widget.cubit != null)
          BlocProvider<BookingCubit>.value(value: widget.cubit!)
        else
          BlocProvider<BookingCubit>(
            create: (_) => BookingCubit(
              getIt<GetBookingRouteUseCase>(),
              fareCalculator: getIt<FareCalculator>(),
              getDriverInfoUseCase: getIt<GetDriverInfoUseCase>(),
              driverArrivalEstimator: getIt<DriverArrivalEstimator>(),
              driverTrackingService: getIt<DriverTrackingService>(),
              initialService: widget.initialService,
              progressController: getIt<BookingProgressController>(),
              flowCoordinator: getIt<BookingFlowCoordinator>(),
              autoRestore: !(widget.isTestOverride ??
                  const bool.fromEnvironment('FLUTTER_TEST')),
              enableSideEffects: !(widget.isTestOverride ??
                  const bool.fromEnvironment('FLUTTER_TEST')),
              pickup: widget.pickup,
              drop: widget.drop,
              pickupLabel: widget.pickupLabel,
              dropLabel: widget.dropLabel,
            ),
          ),
      ],
      child: Builder(
        builder: (context) {
          final bool isTest = widget.isTestOverride ??
              const bool.fromEnvironment('FLUTTER_TEST');
          _bookingCubit ??= context.read<BookingCubit>();
          if (!_autoStartHandled &&
              !isTest &&
              (widget.autoStartSearch ||
                  widget.initialService != null)) {
            _autoStartHandled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final cubit = context.read<BookingCubit>();
              if (widget.autoStartSearch &&
                  cubit.state.driverSearchStatus == DriverSearchStatus.idle) {
                cubit.startDriverSearch();
              }
            });
          }
          return content;
        },
      ),
    );
  }
}
